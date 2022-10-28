import L "mo:base/List";
import HM "mo:base/HashMap";
import T "mo:base/Text";
import I "mo:base/Iter";
import C "mo:base/Char";
import Ti "mo:base/Time";
import Debug "mo:base/Debug";

// local
import TP "igcTrackPoint";
import H "helper";

module {

    // The simple Metadata 
    // TODO maybe extend to 'real' ISO Metadata
    public type Metadata =  {
        trackId: Text;
        timestamp : Ti.Time;
        gliderId : ?Text;
        gliderPilot: ?Text;
        gliderType: ?Text;
        gliderClass: ?Text;
        competitionId: ?Text;
        start : ?Text;
        land: ?Text;
    };

    // The Track will be constructed empty - then added points and header elements
    public class Track () {
        var track : L.List <TP.Trackpoint> = L.nil<TP.Trackpoint>();  
        public var headers : HM.HashMap<Text,Text> = HM.HashMap<Text,Text>(10,T.equal,T.hash);
        let timestamp: Ti.Time = Ti.now();
    
        public func addTrackpoint (tp : TP.Trackpoint)  {
            track := L.push<TP.Trackpoint>(tp,track);
        };

        // some relevant headers for direct access
        // somehow grown TODO Clean
        private func getUnitID () : ?Text {
            headers.get("UnitId")
        };

        private func getGliderID () : ?Text {
            headers.get("FGIDGLIDERID");
        };

        private func getDate () : ?Text {
            headers.get("FDTEDATE");
        };

        private func getPilot () : ?Text {
            headers.get("FPLTPILOTINCHARGE");
        };

        private func getGliderType() : ?Text {
            headers.get("FGTYGLIDERTYPE");
        };

        private func getGliderClass() : ?Text {
            headers.get("FCCLCOMPETITIONCLASS");
        };

        private func getCompetionId() : ?Text {
            headers.get("FCIDCOMPETITIONID");
        };
        
        private func getStart() : H.DateTime {
            return H.toDateTime(H.optionalText(getDate()) # H.optionalText(getStartTime()));
        };

        private func getLand() : H.DateTime {
            return H.toDateTime(H.optionalText(getDate()) # H.optionalText(getLandTime()));
        };

        private func getLandTime () : ?Text {
            switch (L.get<TP.Trackpoint>(track,0)) {
                case null { null };
                case (?tp) {
                    ?tp.timestamp;
                };
            };
        };

        private func getStartTime () : ?Text {
            switch (L.last<TP.Trackpoint>(track)) {
                case null { null };
                case (?tp) {
                    ?tp.timestamp;
                };
            };
        };
    
        // the id of the record derived from unit , date and time
        // TODO change to fileId
        public func getTrackId () : Text {
            H.optionalText(getUnitID()) # H.optionalText(getDate()) # H.optionalText(getStartTime());
        };

        public func getMetadata () : Metadata {
            {
                trackId = getTrackId();
                timestamp = timestamp;
                gliderId = getGliderID();
                gliderPilot = getPilot();
                gliderType = getGliderType();
                gliderClass = getGliderClass();
                competitionId = getCompetionId();
                start = ? H.prettyDateTime(getStart());
                land = ? H.prettyDateTime(getLand());
            };
        };


        private func getJSONLineString() : Text {
            var jsonLineString : Text = "{ \"type\" : \"LineString\", \"coordinates\" :[ ";
            let tpoints : I.Iter<TP.Trackpoint> = L.toIter<TP.Trackpoint> (track);
            var sizeHelper : Nat  = L.size(track);
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
            jsonFeature := T.trimEnd(jsonFeature, #text ",");
            jsonFeature #= "}, \"geometry\": ";
            jsonFeature #= getJSONLineString();
            jsonFeature #= "}";
            return jsonFeature;
        };

        // different representations - Point Feature Collection
        public func getGeoJSONPointCollection () : Text {
            var jsonFeatureCollection : Text = "{\"type\": \"FeatureCollection\", \"features\": [";
            let tpoints : I.Iter<TP.Trackpoint> = L.toIter<TP.Trackpoint> (track);
            var sizeHelper : Nat  = L.size(track);
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
    };

    public func parseIGCTrack (igcText :Text) : Track {
        var track :Track = Track();
        let cr : Char = C.fromNat32(0x000D);
        let nl : Char = C.fromNat32(0x000A);
        let lines = T.tokens(igcText, #char nl);
        for (line in lines) {
            // switch according to the first Letter of a line
            let first :Char = I.toArray(T.toIter(line))[0];
                switch(first) {
                    case('A') {
                        track.headers.put("UnitId", T.trimEnd(T.trimStart(line, #char 'A'), #char cr));
                        //track.unitId := T.trimEnd(T.trimStart(line, #char 'A'), #char cr);
                        };
                    case('H') {
                        Debug.print("Header: " # line);
                        let headerline :Text = T.trimEnd(T.trimStart(line, #char 'H'), #char cr);
                        let it_parts : I.Iter<Text> = T.split(headerline, #char ':');
                        let ar_parts = I.toArray<Text>(it_parts);
                        if(ar_parts.size() == 2) {
                            track.headers.put(ar_parts[0],ar_parts[1]);
                        };                       
                    };
                    case('B'){
                        // Debug.print("Trackpoint: " # line);
                        // if we can parse the Line - add the trackpoint
                        //let tp : ?TP.Trackpoint = TP.parseTrackpoint(line);
                        switch (TP.parseTrackpoint(line)) {
                            case null {
                                Debug.print("cannot read Trackpoint: " # line # "  - parsing error");
                            };
                            case (?(tp)) {
                                Debug.print("Read Trackpoint " # line);
                                track.addTrackpoint(tp);
                            };
                        }
                    };
                    case(trap) {
                        Debug.print("Something else " # line);
                    };
                }  
            };
        return track;
    };
};