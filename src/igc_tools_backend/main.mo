import IGC "igcLog";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

actor {
  var trackmap : IGC.TrackMap = IGC.TrackMap();

  public type metadata =  {
    trackId: Text;
    gliderId : ?Text;
    date : ?Text;
    time : ?Text;
  };

  public func uploadIGC (igcText : Text) : async Text {
    let track : IGC.Track = IGC.parseIGCLog(igcText);
    let newTrackId : Text = trackmap.addTrack(track);
    return (newTrackId);
    //return trackmap.getTracklist();
    //return track.getGeoJSONPointCollection();
    //let igc : IGC.IGCLog = IGC.IGCLog(igcText);
    //return igc.getGeoJSON();
  };

  func getMetadataById (trackId : Text ) : ?metadata {
    switch (trackmap.getTrackById(trackId)) {
      case null {
        Debug.print("Metadata not found");
        null};
      case (?track) {
        Debug.print("Metadata found");
        let md : metadata = {
          trackId = track.getTrackId();
          gliderId = track.getGliderID();
          date = track.getDate();
          time = track.getStartTime();
        };
        ?md;
      };
    };
  };

  public func getTrackList() : async [metadata] {
    let trackIter : Iter.Iter<Text> = trackmap.tracks.keys();
    var trackBuffer : Buffer.Buffer<metadata> = Buffer.Buffer<metadata>(0);
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

  public func getTrackLineGeoJSON (trackId : Text) : async Text {
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