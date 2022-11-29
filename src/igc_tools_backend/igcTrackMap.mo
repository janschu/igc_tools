import I "mo:base/Iter";
import HM "mo:base/HashMap";
import B "mo:base/Buffer";
import T "mo:base/Text";
import R "mo:base/Result";
import Debug "mo:base/Debug";
// Local
import H "helper";
import TR "igcTrack";
import TP "igcTrackPoint";
import DT "dateTime";


module {

    public type Metadata = {
        title : Text;
        description : Text;
        id: Text;
        // TODO: shall we allow enpty flights?
        start : ?DT.DateTime;
        land: ?DT.DateTime;
        bbox: H.BBox;
    };


    public class TrackMap () {
        // Store all Tracks in a HashMap with ID composed of UnitID, Date and Starttime
        // Use additional index to filter planes etc.
        public var tracks : HM.HashMap<Text,TR.Track> = HM.HashMap<Text,TR.Track>(10,T.equal,T.hash); 
        public var metadata : Metadata = {
            title = "Glider Flights";
            description = "Flight Collection";
            id = "FC"; // complete Feature Collection
            bbox = {minLat=0; minLon=0; maxLat=0; maxLon=0};
            start = null;
            land = null;
        };

        // add a track and return the Id
        public func addTrack(track: TR.Track) : Text {
            let trackId : Text = track.getTrackId();
            tracks.put(trackId,track);
            updateMetadata(track);
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

        // update Metadata
        private func updateMetadata(track: TR.Track) {
            metadata := {
                title = "Glider Flights";
                description = metadata.description # " / TrackId: " # track.getTrackId();
                id = metadata.id;
                start = R.toOption(getTemporalStart());
                land = R.toOption(getTemporalEnd());
                bbox = getBBox();
            };
        };

        private func getTemporalStart () : R.Result <DT.DateTime, DT.DateTimeError> {
            var start : DT.DateTime =
                {year = 99;
                month = 12;
                day = 31;
                hour = 23;
                minute = 59;
                sec = 59;};

            let iterTracks : I.Iter<TR.Track> = tracks.vals();
            I.iterate<TR.Track>(iterTracks, func(track, _index) {
                switch (track.getStart()) {
                    case (#err(_)) {};
                    case (#ok(dt)) {
                        if (DT.compare(dt,start) == #before) {
                            start := dt;
                        };
                    };
                };
            });
            if (start.year < 99) {
                return #ok(start);
            }; 
            return #err(#nullError);
        };

        private func getTemporalEnd () : R.Result <DT.DateTime, DT.DateTimeError> {
            var land : DT.DateTime =
                {year = 00;
                month = 12;
                day = 31;
                hour = 23;
                minute = 59;
                sec = 59;};
            let iterTracks : I.Iter<TR.Track> = tracks.vals();
            I.iterate<TR.Track>(iterTracks, func(track, _index) {
                switch (track.getLand()) {
                    case(#err(_)) {};
                    case(#ok(dt)){
                        if (DT.compare(dt,land) == #after) {
                            land := dt;
                        };
                    };
                };
            });
            if (land.year > 00) {
                 return #ok(land);
            }; 
            return #err(#nullError);
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