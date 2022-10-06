import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import List "mo:base/List";

module {

    // Helper from https://forum.dfinity.org/t/subtext-substring-function-in-motoko/11838/2
    public func subText(value : Text, indexStart : Nat, indexEnd : Nat) : Text {
        if (indexStart == 0 and indexEnd >= value.size()) {
            return value;
        }
        else if (indexStart >= value.size()) {
            return "";
        };

        var indexEndValid = indexEnd;
        if (indexEnd > value.size()) {
            indexEndValid := value.size();
        };

        var result : Text = "";
        var iter = Iter.toArray<Char>(Text.toIter(value));
        for (index in Iter.range(indexStart, indexEndValid - 1)) {
            result := result # Char.toText(iter[index]);
        };

        result;
    };

    // Helper from https://forum.dfinity.org/t/motoko-convert-text-123-to-nat-or-int-123/7033/3
    public func textToNat( txt : Text) : Nat {
        assert(txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars){
            let charToNum = Nat32.toNat(Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };
        num;
    };

    public class Trackpoint (trackpointText : Text) {
        var timestamp : Text = "";
        var latDeg : Float = 0;
        var lonDeg : Float = 0;
        var heightGPS : Float = 0;

        // parse a single Trackpoint
        func parseTrackpoint (trackpointText : Text) {
            // Debug.print("Parsing a Trackpoint " # trackpointText);
            // Read by Position
            timestamp := subText(trackpointText, 1, 7);
            let lat :Text = subText(trackpointText,7,14);
            let latFloat :Float = Float.fromInt(textToNat(lat))/100000;
            let ns : Text = subText(trackpointText,14,15);
            if (ns=="N") {
                latDeg := latFloat;     
            }
            else {
                latDeg := -latFloat;
            };
            //Debug.print(debug_show(latDeg));
            let lon :Text = subText(trackpointText,15,23);
            let lonFloat :Float = Float.fromInt(textToNat(lon))/100000;
            let ew : Text = subText(trackpointText,23,24);
            if (ns=="E") {
                lonDeg := -lonFloat;     
            }
            else {
                lonDeg := lonFloat;
            };
            //Debug.print(debug_show(lonDeg));
            //Debug.print("Time: " # timestamp # " Lat: " # lat # " N/S: " # ns # " Lon: " # lon # " E/W: " # ew);
            // is altitude tracked?
            let altcheck : Text = subText(trackpointText,24,25);
            if (altcheck == "A") {
                let alt_pres : Text = subText(trackpointText,25,30);
                let alt_gps : Text = subText(trackpointText,30,35);
                heightGPS := Float.fromInt(textToNat(alt_gps));
                //Debug.print("Alt pres: " # alt_pres # " Alt gps: " # alt_gps);
            }
            else {
                //Debug.print("No Altitude available");
            };
        };

        public func getJSONCoordinate () : Text {
            if (heightGPS != 0) {
                return getJSONCoordinate3D();
            } else {
                return getJSONCoordinate2D();
            };
        };
        
        public func getJSONCoordinate2D () : Text {
            let jsonCoord :Text = "[" # Float.toText(lonDeg) # ", " # Float.toText(latDeg) # "]";
            Debug.print(jsonCoord);
            return jsonCoord; 
        };

        // Height in m above sealevel -
        public func getJSONCoordinate3D () : Text {
            let jsonCoord :Text = "[" # Float.toText(lonDeg) # ", " # Float.toText(latDeg) # ", " # Float.toText(heightGPS) # "]";
            Debug.print(jsonCoord);
            return jsonCoord; 
        };

        // TODO switch to numeric
        public func getTimestamp () : Text {
            return timestamp;
        };

        parseTrackpoint(trackpointText);
    };

    public class Track () {
        var track : List.List <Trackpoint> = List.nil<Trackpoint>();  
        
        public func addTrackpoint (tp : Trackpoint)  {
            Debug.print("add TP: " # tp.getTimestamp());
            track := List.push<Trackpoint>(tp,track);
        };

        public func getJSONLineString() : Text {
            var jsonLineString : Text = "{ \"type\" : \"LineString\", \"coordinates\" :[ ";
            let tpoints : Iter.Iter<Trackpoint> = List.toIter<Trackpoint> (track);
            var sizeHelper : Nat  = List.size(track);
            for (tp in tpoints) {
                sizeHelper -=1;
                jsonLineString := jsonLineString # tp.getJSONCoordinate();
                if (sizeHelper > 0) {
                    jsonLineString := jsonLineString # ",";
                };
            };
            jsonLineString := jsonLineString # "]}";
            return jsonLineString;
        }
    };

    public class IGCLog (igcText :Text) {
        
        var unit_id :Text = "";
        var headers : HashMap.HashMap<Text,Text> = HashMap.HashMap<Text,Text>(10,Text.equal,Text.hash);
        var track :Track = Track();      
        
        // parse the header elements
        func parseHeader (headerText :Text)  {
            Debug.print("Parsing Header Text: " # headerText);
            let it_parts : Iter.Iter<Text> = Text.split(headerText, #char ':');
            let ar_parts = Iter.toArray<Text>(it_parts);
            if(ar_parts.size() == 2) {
                Debug.print("Header: " # ar_parts[0] # " - " # ar_parts[1]);
                headers.put(ar_parts[0],ar_parts[1]);
            } 
            else {
                Debug.print("-");
            };            
        };

        // Parser
        func parseText (igcText :Text) {
            let cr : Char = Char.fromNat32(0x000D);
            let nl : Char = Char.fromNat32(0x000A);
            let lines = Text.tokens(igcText, #char nl);
            for (line in lines) {
                // switch according to the first Letter of a line
                let first :Char = Iter.toArray(Text.toIter(line))[0];
                switch(first) {
                    case('A') {
                        unit_id := Text.trimEnd(Text.trimStart(line, #char 'A'), #char cr);
                        Debug.print("Unit Id: " # unit_id);
                        };
                    case('H') {
                        Debug.print("Header: " # line);
                        let headerline :Text = Text.trimEnd(Text.trimStart(line, #char 'H'), #char cr);
                        parseHeader(headerline);
                    };
                    case('B'){
                        Debug.print("Trackpoint: " # line);
                        let dummy : Trackpoint = Trackpoint(line);
                        track.addTrackpoint(dummy);
                        Debug.print("JSON Coordinate: " # dummy.getJSONCoordinate());
                    };
                    case(trap) {
                        //Debug.print("Trap");
                    };
                }  
            };
        };

        // TODO Fix
        public func getFlarmId () : ?Text {
            //unit_id;
            let values = headers.vals();
            for (val in values) {
                Debug.print(val);
            };
            return headers.get("HFPLTPILOTINCHARGE");
        };

        public func getGeoJSON () : Text {
            var jsonFeature : Text = "{\"type\": \"Feature\", \"properties\": {";
            // TODO refactor header attributes as class
            // TODO filter all empty attributes
            let entries = headers.entries();
            for (entry in entries) {
                if (entry.1 != "") {
                    jsonFeature #= "\"" # entry.0 # "\": \"" # entry.1 # "\"";
                    jsonFeature #=",";
                };
            };
            // remove the last ,
            jsonFeature := Text.trimEnd(jsonFeature, #text ",");
            jsonFeature #= "}, \"geometry\": ";
            jsonFeature #= track.getJSONLineString();
            jsonFeature #= "}";
            return jsonFeature;
        };

        parseText(igcText);
        Debug.print("Finished Parsing");
    };
};