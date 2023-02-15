import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";

// local
import H "helper";
import TR "igcTrack";
import TM "igcTrackMap";
import OR "ogcApiRoot";
import OC "ogcApiCollections";
import OCS "ogcApiCollectionsSingle";
import OCSI "ogcApiCollectionsSingleItems";
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

  // private type formatType = {#html; #json; #undefined};
  
  private type URLPattern = {
    path : [Text];
    queryParams : [(Text,Text)];
    format : H.Representation;
  };

  private func parseURL (request : HttpRequest) : URLPattern {
    Debug.print("Function: parseURL");
    Debug.print("Request Method: " # request.method);
    Debug.print("Request URL" # request.url);
    Debug.print("Request Headers" # debug_show(request.headers));
    Debug.print("Request Body" # debug_show(request.body));
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
    let qp : [(Text, Text)] = kvpBuffer.toArray();
    // Check the requested format - query param with higher priority
    var rf : H.Representation = getResponseFormatQuery(qp);
    if (rf == #undefined) {
      rf := getResponseFormatHeader (request.headers);
    };
    return {
      path = pathComponents;
      queryParams = qp;
      format = rf;
    };
  };

  private func getResponseFormatQuery (queryParams: [(Text, Text)]): H.Representation {
    let format : ?(Text,Text) = Array.find<(Text,Text)>(queryParams, func (x) {x.0 =="f"});
    switch format {
      case (?pair) {
        if (pair.1=="html" or pair.1=="HTML") {return #html} 
        else if (pair.1=="json" or pair.1=="JSON") {return #json}
        else return #undefined;
      };
      case (_) {
        return #undefined;
      };
    };
  };

  private func getResponseFormatHeader(requestHeaders: [KVP]): H.Representation {
    let format : ?KVP = Array.find<KVP>(requestHeaders, func (x) {x.0 == "accept"});
    switch format {
      case (?pair) {
        if (Text.contains(pair.1,#text("application/json"))){return #json}
        else if (Text.contains(pair.1,#text("text/html"))){return #html}
        else return #undefined;
      };
      case (_) {
        return #undefined;
      };
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
    Debug.print("Function HttpRequest");
    let urlPattern : URLPattern = parseURL(request);
    
    Debug.print(debug_show(urlPattern));
    // test the possible combinations
    // Root
    if (urlPattern.path.size() == 0) {
      return {
          status_code = 200;
          headers = [];
          body = Text.encodeUtf8(OR.getRootPage(trackmap,baseURL,urlPattern.format));
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
          body = Text.encodeUtf8(OC.getCollectionsPage(trackmap,baseURL,urlPattern.format));
          };
    };
    // Single Collections
    if (urlPattern.path.size() == 2 and urlPattern.path[0] == "collections") {
      // Check the overall Feature Collection - hardcoded pattern
        if (urlPattern.path[1] == "FC") {
          return {
            status_code = 200;
            headers = [];
            body = Text.encodeUtf8(OCS.getCollectionsSingleMap (trackmap,baseURL,urlPattern.format));
          };  
        };
        switch (trackmap.getTrackById(urlPattern.path[1])) {
          case (?(track)) {
            return {
              status_code = 200;
              headers = [];
              body = Text.encodeUtf8(OCS.getCollectionsSingleTrack(track,baseURL,urlPattern.format));
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
            body = Text.encodeUtf8(OCSI.getCollectionsSingleMapItems(trackmap,baseURL,urlPattern.format));
            // body = Text.encodeUtf8(trackmap.getGeoJSONLineCollection ());
          };  
        };
        switch (trackmap.getTrackById(urlPattern.path[1])) {
          case (?(track)) {
            return {
              status_code = 200;
              headers = [];
              body = Text.encodeUtf8(OCSI.getCollectionsSingleTrackItems(track,baseURL,urlPattern.format));
              // body = Text.encodeUtf8(track.getGeoJSONPointCollection());
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