import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

// local
import TR "igcTrack";
import TM "igcTrackMap";
import OR "ogcApiRoot";
import OC "ogcApiCollections";
import OCS "ogcApiCollectionsSingle";
import OCF "ogcApiConformance";

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
 
  // private func splitURLParams (url: Text) : (Text, ?Text) {
  //   let urlparts : Iter.Iter <Text> = Text.split(url, #char '?');
  //   switch (urlparts.next()) {
  //     case (? text) {
  //       return (text,urlparts.next());
  //     };
  //     case null {
  //       return (url, urlparts.next());
  //     };
  //   };
  // };

  private type URLPattern = {
    path : [Text];
    queryParams : [(Text,Text)];
    format : {#html;#json;#undefined};
  };

  private func parseURL (request : HttpRequest) : URLPattern {
    // split path and queryParams -> result shall be of size 1 or 2
    let urlparts : [Text] = Iter.toArray(Text.tokens(request.url, #char '?'));
    // split path components
    let pathComponents : [Text] = Iter.toArray(Text.tokens(urlparts[0], #char '/'));
    // split query elements
    var kvpBuffer : Buffer.Buffer <(Text,Text)> = Buffer.Buffer <(Text,Text)> (0);
    if (urlparts.size() > 1) {
      let queryIter : Iter.Iter<Text> = Text.split(urlparts[1], #char '&');
      // split KVP 
      Iter.iterate<Text>(queryIter, func (item, _index) {
        let kvp: [Text] = Iter.toArray(Text.split(item, #char '='));
        kvpBuffer.add((kvp[0],kvp[1]));
      });
    };
    // TODO Check the requested format
    // currently fixed to json
    return {
      path = pathComponents;
      queryParams = kvpBuffer.toArray();
      format = #json;
    };
  };

  // Endpoints:
  // / : Landing Page - the service and the endpoint list
  // /conformance: static conformance page
  // /api: desribing the endpoints and the document structure
  // /collections: List of all collections/layers
  // /collections/{id}: Information on the collection 
  // /collections/{id}/items: Feature Collection
  // /collections/{id}/items/{featureid}: A single feature
  //
  // TODO: Filter BBOX, DateTime
  public query func http_request(request : HttpRequest) : async HttpResponse {  
    let urlPattern : URLPattern = parseURL(request);
    Debug.print(debug_show(urlPattern));
    // test the possible combinations
    // Root
    if (urlPattern.path.size() == 0) {
      return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OR.getRootPage(trackmap,baseURL,#json));
          };
    };
    // Conformance
    if (urlPattern.path.size() == 1 and urlPattern.path[0] == "conformance") {
      return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OCF.getConformancePage(#json));
          };
    };   
    // Collections
    if (urlPattern.path.size() == 1 and urlPattern.path[0] == "collections") {
      return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OC.getCollectionsPage(trackmap,baseURL,#json));
          };
    };
    // Single Collections
    if (urlPattern.path.size() == 2 and urlPattern.path[0] == "collections") {
      // Check the overall Feature Collection - hardcoded pattern
        if (urlPattern.path[1] == "FC") {
          return {
            status_code = 200;
            headers = [];
            body = Text.encodeUtf8(OCS.getCollectionsSingleMap (trackmap,baseURL,#json));
          };  
        };
        switch (trackmap.getTrackById(urlPattern.path[1])) {
          case (?(track)) {
            return {
              status_code = 200;
              headers = [];
              body = Text.encodeUtf8(OCS.getCollectionsSingleTrack(track,baseURL,#json));
            };
          };
          case _ {
            return {
              status_code = 404;
              headers = [];
              body = Text.encodeUtf8("No track found");
           };
          };
        }
    };    
    // Items
      if (urlPattern.path.size() == 3 and urlPattern.path[0] == "collections" and urlPattern.path[2] == "items") {
        // Check the overall Feature Collection - hardcoded pattern
        if (urlPattern.path[1] == "FC") {
          return {
            status_code = 200;
            headers = [];
            body = Text.encodeUtf8(trackmap.getGeoJSONLineCollection ());
          };  
        };
        switch (trackmap.getTrackById(urlPattern.path[1])) {
          case (?(track)) {
            return {
              status_code = 200;
              headers = [];
              body = Text.encodeUtf8(track.getGeoJSONPointCollection());
            };
          };
          case _ {
            return {
              status_code = 404;
              headers = [];
              body = Text.encodeUtf8("No track found");
           };
          };
        };      
    };


    switch ("/error") {
      case ("/") {
        return {
          status_code = 404;
          headers = [];
          body = Text.encodeUtf8("404 Errorpage");
          };
      };
      case ("/collections") {
        return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OC.getCollectionsPage(trackmap,baseURL,#json));
          };
      };
      // todo check the .../items
      case _ {
          return {
          status_code = 404;
          headers = [];
          body = Text.encodeUtf8("404 Errorpage");
          };
      };
    };
    ///
  };

  ///////





  
  var trackmap : TM.TrackMap = TM.TrackMap();

  public func getOGCRootMetadata () : async TM.Metadata {
    return trackmap.metadata;
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