import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

// local
import TR "igcTrack";
import TM "igcTrackMap";
import OR "ogcApiRoot";

actor { 
  // all HTTP handling from motoko mailing list
  // TODO split IGC Data from OGC representation
  // fix the base URL
  let baseURL : Text = "https://mtlom-hiaaa-aaaah-abtkq-cai.raw.ic0.app";
  type KVP = (Text, Text);


  type HttpRequest = {
    method : Text;
    url : Text;
    headers : [KVP];
    body : Blob;
  };

  type HttpResponse = {
    status_code : Nat16;
    headers : [KVP];
    body : Blob;
  };
 
  private func getURLParts (url: Text) : (Text, ?Text) {
    let urlparts : Iter.Iter <Text> = Text.split(url, #char '?');
    switch (urlparts.next()) {
      case (? text) {
        return (text,urlparts.next());
      };
      case null {
        return (url, urlparts.next());
      };
    };
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {  
    // split according to REST pattern
    let path : Text = getURLParts(request.url).0;
    Debug.print("Path: '"#path#"'");
    switch (path) {
      case ("/") {
        return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OR.getRootPage(trackmap,baseURL,#json));
          };
      };
      case _ {
        Debug.print("null");
      };
    };
    ///
    if (path =="/") { 
  
    };
    return {
        status_code = 404;
        headers = [];
        body = Text.encodeUtf8("Not found");
      }; 
  };

  ///////





  // TODO Make stable
  var trackmap : TM.TrackMap = TM.TrackMap();

  public func getOGCRootMetadata () : async TM.Metadata {
    return trackmap.getMetadata();
  };

  public func uploadIGC (igcText : Text) : async Text {
    let track : TR.Track = TR.parseIGCTrack(igcText);
    let newTrackId : Text = trackmap.addTrack(track);
    return (newTrackId);
    //return trackmap.getTracklist();
    //return track.getGeoJSONPointCollection();
    //let igc : IGC.IGCLog = IGC.IGCLog(igcText);
    //return igc.getGeoJSON();
  };

  func getMetadataById (trackId : Text ) : ?TR.Metadata {
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

  public query func getTrackList() : async [TR.Metadata] {
    let trackIter : Iter.Iter<Text> = trackmap.tracks.keys();
    var trackBuffer : Buffer.Buffer<TR.Metadata> = Buffer.Buffer<TR.Metadata>(0);
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