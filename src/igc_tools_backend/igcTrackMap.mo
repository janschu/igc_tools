import I "mo:base/Iter";
import HM "mo:base/HashMap";
import B "mo:base/Buffer";
import T "mo:base/Text";
import Debug "mo:base/Debug";
// Local
import H "helper";
import TR "igcTrack";
import TP "igcTrackPoint";



module {

    public type Metadata = {
        title : Text;
        description : Text;
        id: Text;
        start : ?H.DateTime;
        land: ?H.DateTime;
        bbox: H.BBox;
    };

    public class TrackMap () {
        // Store all Tracks in a HashMap with ID composed of UnitID, Date and Starttime
        // Use additional index to filter planes etc.
        public var tracks : HM.HashMap<Text,TR.Track> = HM.HashMap<Text,TR.Track>(10,T.equal,T.hash); 

        // add a track and return the Id
        public func addTrack(track: TR.Track) : Text {
            let trackId : Text = track.getTrackId();
            tracks.put(trackId,track);
            return trackId;
        };
 
        // for testing the tracklist as Text [] of TrackIds
        public func getTracklist () : [Text] {
            let keyIter : I.Iter<Text> = tracks.keys();
            var tracklist : B.Buffer<Text> = B.Buffer<Text>(0);
            for (key in keyIter) {
                tracklist.add(key);
            };
            return tracklist.toArray();
        };

        // simple wrapper
        public func getTrackById (trackId : Text ) : ? TR.Track {
            tracks.get(trackId);
        };

        // hardcoded Metadata
        public func getMetadata() : Metadata {
            return {
                title = "Glider Flights";
                description = "Some Recorded Flights";
                id = "FC";
                start = getTemporalStart();
                land = getTemporalEnd();
                bbox = getBBox();
            };
        };

        private func getTemporalStart () : ?H.DateTime {
            var start : H.DateTime =
                {year = 99;
                month = 12;
                day = 31;
                hour = 23;
                minute = 59;
                sec = 59;};

            let iterTracks : I.Iter<TR.Track> = tracks.vals();
            I.iterate<TR.Track>(iterTracks, func(track, _index) {
                    if (H.compare(track.getStart(),start) == #before) {
                        start := track.getStart();
                    };
                });
            if (start.year < 99) {
                return ?start;
            }; 
            return null;
        };

        private func getTemporalEnd () : ?H.DateTime {
            var land : H.DateTime =
                {year = 00;
                month = 12;
                day = 31;
                hour = 23;
                minute = 59;
                sec = 59;};
            let iterTracks : I.Iter<TR.Track> = tracks.vals();
            I.iterate<TR.Track>(iterTracks, func(track, _index) {
                    if (H.compare(track.getLand(),land) == #after) {
                        land := track.getLand();
                    };
                });
            if (land.year > 00) {
                 return ?land;
            }; 
            return null;
        };

        private func getBBox () : H.BBox {
            var box : H.BBox = {minLat=0; minLon=0; maxLat=0; maxLon=0};
            let iterTracks : I.Iter<TR.Track> = tracks.vals();
            I.iterate<TR.Track>(iterTracks, func(track, _index) {
                if (_index==0) {
                    box := track.getBBox();
                } else {
                    box := H.extendBBox(box,track.getBBox());
                }
            });
            return box;
        };


        // one collection with all Line Features
        // a collection with one feature
        public func getGeoJSONLineCollection () : Text {
            var jsonFeatureCollection : Text = "{\"type\": \"FeatureCollection\", \"features\": [";
            let iterTracks : I.Iter<TR.Track> = tracks.vals();
                I.iterate<TR.Track>(iterTracks, func(track, _index) {
                    jsonFeatureCollection #= track.getGeoJSONLineFeature();
                    if (_index+1 < tracks.size()){
                        jsonFeatureCollection #= ",";
                    };
                });
            jsonFeatureCollection #= "]}";
            return jsonFeatureCollection;
        };
    };
};