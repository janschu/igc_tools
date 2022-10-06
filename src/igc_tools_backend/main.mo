import IGC "igcLog";

actor {
  public func uploadIGC (igcText : Text) : async Text {
    let igc : IGC.IGCLog = IGC.IGCLog(igcText);
    return igc.getGeoJSON();
  };
};