import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
// local
import TR "igcTrack";
import TM "igcTrackMap";
actor {
  // TODO Make stable
  var trackmap : TM.TrackMap = TM.TrackMap();

  public func uploadIGC (igcText : Text) : async Text {
    let track : TR.Track = TR.parseIGCTrack(igcText);
    let newTrackId : Text = trackmap.addTrack(track);
    return (newTrackId);
    //return trackmap.getTracklist();
    //return track.getGeoJSONPointCollection();
    //let igc : IGC.IGCLog = IGC.IGCLog(igcText);
    //return igc.getGeoJSON();
  };

  func getMetadataById (trackId : Text ) : ?TR.metadata {
    switch (trackmap.getTrackById(trackId)) {
      case null {
        Debug.print("Metadata not found");
        null};
      case (?track) {
        Debug.print("Metadata found");
        return ?track.getMetadata();
      };
    };
  };

  public query func getTrackList() : async [TR.metadata] {
    let trackIter : Iter.Iter<Text> = trackmap.tracks.keys();
    var trackBuffer : Buffer.Buffer<TR.metadata> = Buffer.Buffer<TR.metadata>(0);
    for (trackId in trackIter) {
      Debug.print("Search Id " # trackId);
      switch (getMetadataById(trackId)) {
        case (null) {
          Debug.print("Metadata not found by caller - shall not happen");
        };
        case (?md) {
          trackBuffer.add(md);
        };
      };
    };
    return trackBuffer.toArray();
  };

  public query func getTrackLineGeoJSON (trackId : Text) : async Text {
    switch (trackmap.getTrackById(trackId)) {
      case null {
        Debug.print("GeoJSON not found");
        "";
      };
      case (?track) {
        Debug.print("GeoJSON found");
        track.getGeoJSONLineFeature();
      };
    }
  };
}