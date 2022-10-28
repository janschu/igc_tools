import F "mo:base/Float";
import Debug "mo:base/Debug";
// local
import H "helper";

module {

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
            Debug.print(jsonCoord);
            return jsonCoord; 
        };

        // Height in m above sealevel -
        public func getJSONCoordinate3D () : Text {
            let jsonCoord :Text = "[" # F.toText(lonDeg) # ", " # F.toText(latDeg) # ", " # F.toText(heightGPS) # "]";
            Debug.print(jsonCoord);
            return jsonCoord; 
        };

        public func getJSONPointFeature () : Text {
            var jsonFeature : Text = "{\"type\": \"Feature\", \"geometry\": {\"type\": \"Point\", \"coordinates\":";
            jsonFeature #= getJSONCoordinate2D();
            jsonFeature #= "}, \"properties\":{\"timestamp\": \"" # timestamp # "\", \"gpsheight\": " # F.toText(heightGPS) # "}}";
            return jsonFeature;
        };
    };

    public func parseTrackpoint(trackpointText: Text) : ?Trackpoint {
        // Debug.print("Parsing a Trackpoint " # trackpointText);
        // Read by Position
        let tp : Trackpoint = Trackpoint();
        tp.timestamp := H.subText(trackpointText, 1, 7);
        let lat :Text = H.subText(trackpointText,7,14);
        let latFloat :Float = F.fromInt(H.textToNat(lat))/100000;
        let ns : Text = H.subText(trackpointText,14,15);
        if (ns=="N") {
            tp.latDeg := latFloat;     
        }
        else {
            tp.latDeg := -latFloat;
        };
        let lon :Text = H.subText(trackpointText,15,23);
        let lonFloat :Float = F.fromInt(H.textToNat(lon))/100000;
        let ew : Text = H.subText(trackpointText,23,24);
        if (ns=="E") {
            tp.lonDeg := -lonFloat;     
        }
        else {
            tp.lonDeg := lonFloat;
        };
        //Debug.print(debug_show(lonDeg));
        //Debug.print("Time: " # timestamp # " Lat: " # lat # " N/S: " # ns # " Lon: " # lon # " E/W: " # ew);
        // is altitude tracked?
        let altcheck : Text = H.subText(trackpointText,24,25);
        if (altcheck == "A") {
            let alt_pres : Text = H.subText(trackpointText,25,30);
            let alt_gps : Text = H.subText(trackpointText,30,35);
            tp.heightGPS := F.fromInt(H.textToNat(alt_gps));
            //Debug.print("Alt pres: " # alt_pres # " Alt gps: " # alt_gps);
        }
        else {
            //Debug.print("No Altitude available");
        }; 

        // TODO Deal with parsing errors
        return ?tp;

    };

}