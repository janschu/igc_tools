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
        public var timestamp : Text = "";
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

        // switch according to height information
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

        public func getJSONPointFeature () : Text {
            var jsonFeature : Text = "{\"type\": \"Feature\", \"geometry\": {\"type\": \"Point\", \"coordinates\":";
            jsonFeature #= getJSONCoordinate2D();
            jsonFeature #= "}, \"properties\":{\"timestamp\": \"" # timestamp # "\", \"gpsheight\": " # Float.toText(heightGPS) # "}}";
            return jsonFeature;
        };

        parseTrackpoint(trackpointText);
    };

    // The Track will be constructed empty - then added points and header elements
    public class Track () {
        var track : List.List <Trackpoint> = List.nil<Trackpoint>(); 
        public var headers : HashMap.HashMap<Text,Text> = HashMap.HashMap<Text,Text>(10,Text.equal,Text.hash); 
    
        public func addTrackpoint (tp : Trackpoint)  {
            track := List.push<Trackpoint>(tp,track);
        };

        private func getJSONLineString() : Text {
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
        };

        // different representations - single LineFeature
        public func getGeoJSONLineFeature() : Text {
            var jsonFeature : Text = "{\"type\": \"Feature\", \"properties\": {";
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
            jsonFeature #= getJSONLineString();
            jsonFeature #= "}";
            return jsonFeature;
        };

        // different representations - Point Feature Collection
        public func getGeoJSONPointCollection () : Text {
            var jsonFeatureCollection : Text = "{\"type\": \"FeatureCollection\", \"features\": [";
            let tpoints : Iter.Iter<Trackpoint> = List.toIter<Trackpoint> (track);
            var sizeHelper : Nat  = List.size(track);
            for (tp in tpoints) {
                sizeHelper -=1;
                jsonFeatureCollection #= tp.getJSONPointFeature ();
                if (sizeHelper > 0) {
                    jsonFeatureCollection := jsonFeatureCollection # ",";
                };
            };
            jsonFeatureCollection #= "]}";
            return jsonFeatureCollection;
        };

        public func getTrackId () : Text {
            // get Unit ID
            let unitID : Text = optionalText(headers.get("UnitId"));
            let trackDate : Text = optionalText(headers.get("FDTEDATE"));
            var trackId : Text = unitID # trackDate;
            switch (List.last<Trackpoint>(track)){
                case (null) {
                    return trackId;
                };
                case (?id) {
                    return trackId # id.timestamp;
                };
            };
        };

        private func optionalText (a: ?Text) : Text {
            switch (a) {
                case (null) {
                    return "";
                };
                case(?text) {
                    return text;
                };
            };
        };

    };

    public class TrackMap () {
        // Store all Tracks in a HashMap with ID composed of UnitID, Date and Starttime
        // Use additional index to filter planes etc.
        var tracks : HashMap.HashMap<Text,Track> = HashMap.HashMap<Text,Track>(10,Text.equal,Text.hash); 

        // add a track and return the Id
        public func addTrack(track: Track) : Text {
            tracks.put(track.getTrackId(),track);
            return track.getTrackId();
        };

        // for testing the tracklist as Text
        public func getTracklist () : Text {
            let keyIter : Iter.Iter<Text> = tracks.keys();
            var tracklist : Text = "- ";
            for (key in keyIter) {
                tracklist #= key # "- ";
            };
            return tracklist;
        };
    };
    
    public func parseIGCLog (igcText :Text) : Track {
        var track :Track = Track();
        let cr : Char = Char.fromNat32(0x000D);
        let nl : Char = Char.fromNat32(0x000A);
        let lines = Text.tokens(igcText, #char nl);
        for (line in lines) {
            // switch according to the first Letter of a line
            let first :Char = Iter.toArray(Text.toIter(line))[0];
                switch(first) {
                    case('A') {
                        track.headers.put("UnitId", Text.trimEnd(Text.trimStart(line, #char 'A'), #char cr));
                        //track.unitId := Text.trimEnd(Text.trimStart(line, #char 'A'), #char cr);
                        };
                    case('H') {
                        Debug.print("Header: " # line);
                        let headerline :Text = Text.trimEnd(Text.trimStart(line, #char 'H'), #char cr);
                        let it_parts : Iter.Iter<Text> = Text.split(headerline, #char ':');
                        let ar_parts = Iter.toArray<Text>(it_parts);
                        if(ar_parts.size() == 2) {
                            track.headers.put(ar_parts[0],ar_parts[1]);
                        };                       
                    };
                    case('B'){
                        Debug.print("Trackpoint: " # line);
                        let tp : Trackpoint = Trackpoint(line);
                        track.addTrackpoint(tp);
                        Debug.print("JSON Coordinate: " # tp.getJSONCoordinate());
                    };
                    case(trap) {
                        Debug.print("Trap");
                    };
                }  
            };

        return track;
    };

};