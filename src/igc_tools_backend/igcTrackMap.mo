import I "mo:base/Iter";
import HM "mo:base/HashMap";
import B "mo:base/Buffer";
import T "mo:base/Text";
// Local
import H "helper";
import TR "igcTrack";
import TP "igcTrackPoint";



module {

    public type Metadata = {
        title : Text;
        description : Text;
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
            };
        };
    };
};