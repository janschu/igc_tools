import IGC "igcLog";

actor {
  var trackmap : IGC.TrackMap = IGC.TrackMap();

  public func uploadIGC (igcText : Text) : async Text {
    let track : IGC.Track = IGC.parseIGCLog(igcText);
    let newTrackId : Text = trackmap.addTrack(track);
    return trackmap.getTracklist();
    //return track.getGeoJSONPointCollection();
    //let igc : IGC.IGCLog = IGC.IGCLog(igcText);
    //return igc.getGeoJSON();
  };
};