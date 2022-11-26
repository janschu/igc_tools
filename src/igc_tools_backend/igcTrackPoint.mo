import F "mo:base/Float";
import R "mo:base/Result";
import Debug "mo:base/Debug";
// local
import H "helper";

module {

    // Errors
    public type ParseError = {#parseNumberError : Text; #recordLengthError};

    public class Trackpoint () {
        public var timestamp : Text = "";
        public var latDeg : Float = 0;
        public var lonDeg : Float = 0;
        public var heightGPS : Float = 0;

        // switch according to height information
        public func getJSONCoordinate () : Text {
            if (heightGPS != 0) {
                return getJSONCoordinate3D();
            } else {
                return getJSONCoordinate2D();
            };
        };
        
        public func getJSONCoordinate2D () : Text {
            let jsonCoord :Text = "[" # F.toText(lonDeg) # ", " # F.toText(latDeg) # "]";
            //Debug.print(jsonCoord);
            return jsonCoord; 
        };

        // Height in m above sealevel -
        public func getJSONCoordinate3D () : Text {
            let jsonCoord :Text = "[" # F.toText(lonDeg) # ", " # F.toText(latDeg) # ", " # F.toText(heightGPS) # "]";
            // Debug.print(jsonCoord);
            return jsonCoord; 
        };

        public func getJSONPointFeature () : Text {
            var jsonFeature : Text = "{\"type\": \"Feature\", \"geometry\": {\"type\": \"Point\", \"coordinates\":";
            jsonFeature #= getJSONCoordinate2D();
            jsonFeature #= "}, \"properties\":{\"timestamp\": \"" # timestamp # "\", \"gpsheight\": " # F.toText(heightGPS) # "}}";
            return jsonFeature;
        };
    };

    public func parseTrackpoint(trackpointText: Text) : R.Result <Trackpoint, ParseError> {
        // Debug.print("igcTrackPoint parseTrackpoint: " # trackpointText);
        // Check Length
        if (trackpointText.size() < 35) {
            Debug.print("igcTrackPoint parseTrackpoint: RecordLengthError: " # trackpointText # " Length: " # debug_show(trackpointText.size()));
            return #err(#recordLengthError);
        };
        // Read by Position
        let tp : Trackpoint = Trackpoint();
        tp.timestamp := H.subText(trackpointText, 1, 7); // TODO Better check the format or use DateTime
        let lat :Text = H.subText(trackpointText,7,14);        
        let ns : Text = H.subText(trackpointText,14,15);
       
        let lon :Text = H.subText(trackpointText,15,23);
        let ew : Text = H.subText(trackpointText,23,24);

        // Debug.print("Time: " # tp.timestamp # " Lat: " # lat # " N/S: " # ns # " Lon: " # lon # " E/W: " # ew);
        // is altitude tracked?
        let altcheck : Text = H.subText(trackpointText,24,25);
        if (altcheck == "A") {           
            let alt_pres : Text = H.subText(trackpointText,25,30);
            let alt_gps : Text = H.subText(trackpointText,30,35);
            switch (H.textToNat(alt_gps)) {
                case (#err(_)) {
                    Debug.print ("igcTrackPoint parseTrackpoint: Error in parsing height: " # alt_gps); 
                    return #err(#parseNumberError("Error in parsing height: " # alt_gps));
                };
                case (#ok(height)) {
                    tp.heightGPS := F.fromInt(height);
                };
            };
        }
        else {
            Debug.print("igcTrackPoint parseTrackpoint: No Altitude available");
        }; 
        // Lat 
        switch (H.textToNat(lat)) {
            case (#err(_)) {
                return #err(#parseNumberError("igcTrackPoint parseTrackpoint: Error in parsing lat: " # lat));
            };
            case (#ok(latNat)) {
                let latFloat :Float = F.fromInt(latNat)/100000;
                if (ns=="N") {
                    tp.latDeg := latFloat;     
                } else {
                    tp.latDeg := -latFloat;
                };
            };
        };
        // Lon 
        switch (H.textToNat(lon)) {
            case (#err(_)) {
                return #err(#parseNumberError("igcTrackPoint parseTrackpoint: Error in parsing lon: " # lon));
            };
            case (#ok(lonNat)) {
                let lonFloat :Float = F.fromInt(lonNat)/100000;
                if (ns=="E") {
                    tp.lonDeg := -lonFloat;     
                } else {
                    tp.lonDeg := lonFloat;
                };
            };
        };
        return #ok(tp);
    };
}