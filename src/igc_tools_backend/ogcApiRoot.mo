import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";
import JH "jsonHelper";
import HTML "htmlHelper";


module {


    public func getRootPage (map: TM.TrackMap, baseURL: Text, repr: H.Representation ): Text {
        if (repr == #json) {
            return getRootJSON(map,baseURL);
        } else {
            return getRootHTML(map,baseURL);
       };
    };


    // TODO Remove? - Double with collection
    // One API Entry per Track
    private func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONTrackText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # JH.lb() # "Glider : " # H.optionalText(metadata.gliderId) # JH.lb() # "Start: " # H.optionalText(metadata.start)),
            ? metadata.trackId,
            ? (baseURL # "/" # metadata.trackId),
            ["Flight", "Track", H.optionalText(metadata.gliderId), H.optionalText(metadata.gliderPilot), H.optionalText(metadata.competitionId)],
            true
        );
    };
    
    // One API Entry per Track
    // Input as TextFields
    private func apiJSONTrackText (title: ?Text, description: ?Text, id: ?Text, landingPage: ?Text, tags: [Text], isDataset: Bool) : Text {
        // Open
        var text : Text = "{" # JH.lb();
        text #= JH.optKvpJSON("title",title,true);
        text #= JH.optKvpJSON("description",description,true);
        text #= JH.optKvpJSON("id",id,true);
        text #= JH.optKvpJSON("landingPageUri",landingPage,true);
        text #= "\"tags\":" # JH.textArrayJSON(tags) # ",";
        if (isDataset) {
            text #= "\"isDataset\": true";
        }
        else {
            text #= "\"isDataset\": false";
        };
        // close 
        text #= "}";
        return text;
    };

    // JSON Representation
    // Sample Response
    // {
    //   "title": "Buildings in Bonn",
    //   "description": "Access to data about buildings in the city of Bonn via a Web API that conforms to the OGC API Features specification.",
    //   "links": [
    //     { "href": "http://data.example.org/",
    //       "rel": "self", "type": "application/json", "title": "this document" },
    //     { "href": "http://data.example.org/api",
    //       "rel": "service-desc", "type": "application/vnd.oai.openapi+json;version=3.0", "title": "the API definition" },
    //     { "href": "http://data.example.org/api.html",
    //       "rel": "service-doc", "type": "text/html", "title": "the API documentation" },
    //     { "href": "http://data.example.org/conformance",
    //       "rel": "conformance", "type": "application/json", "title": "OGC API conformance classes implemented by this server" },
    //     { "href": "http://data.example.org/collections",
    //       "rel": "data", "type": "application/json", "title": "Information about the feature collections" }
    //   ]
    // }
    private func getRootJSON (map: TM.TrackMap, baseURL: Text) : Text {
        // Open
        var body : Text = "{" # JH.lb();
        // Metadata
        body #= JH.kvpJSON("title", map.metadata.title, true);
        body #= JH.kvpJSON("description", map.metadata.description, true);

        // catalog
        // body #= JH.kvpJSON("catalogUri", baseURL,true);
        // Links
        body #= "\"links\": " # "[" # JH.lb();
        body #=JH.linkJSON("self", "application/json", "This document as JSON", baseURL#"?f=json");
        body #=","#JH.lb();
        body #=JH.linkJSON("alternate", "text/html", "This document as HTML", baseURL#"?f=html");
        body #=","#JH.lb();
        body #=JH.linkJSON("conformance", "application/json",  "Conformance as JSON", baseURL#"/conformance?f=json");
        body #=","#JH.lb();
        body #=JH.linkJSON("conformance", "text/html",  "Conformance as HTML", baseURL#"/conformance?f=html");
        body #=","#JH.lb();
        // dummies
        body #=JH.linkJSON("service-desc", "application/vnd.oai.openapi+json;version=3.0", "The OpenAPI definition as JSON", "https://api.weather.gc.ca/openapi");
        body #=","#JH.lb();
        body #=JH.linkJSON("service-doc", "text/html", "The OpenAPI definition as HTML", "https://api.weather.gc.ca/openapi?f=html");
        body #=","#JH.lb();
        // collections
        body #=JH.linkJSON("data", "application/json",  "Collections", baseURL#"/collections?f=json");
        body #= "]"#JH.lb();
        // collections
        body #= ",\"apis\": [" # JH.lb();
        // // Loop all Tracks as single API Entriepoints
        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            body #= apiJSONTrack(track,baseURL);
            if (_index+1 < map.tracks.size()){
                body #= ",";
            };
            body #= JH.lb();
        });

        body #= "]" # JH.lb();
        // Close
        body #= "}";

        return body; 
    };

    // HTML Representation
    // not implemented 
    private func getRootHTML (map: TM.TrackMap, baseURL: Text) : Text {
        // - Head
        var head : Text = HTML.create_MetaCharset("utf-8");
        head #= HTML.create_MetaNameContent("viewport","width=device-width, initial-scale=1" );
        head #= HTML.create_Link("stylesheet", "https://cdn.simplecss.org/simple.min.css");
        
        // - Body Parts

        // - - Header Parts
        var headerContent :Text = "";
        // - - - Nav
        var navContent : Text = "";
        navContent #= HTML.create_A("JSON", "/?f=JSON", null, null);
        navContent #= HTML.create_A("Home", "/", null, ?"current");
        // - - Header
        headerContent #= HTML.create_Nav(navContent,null,null);
        headerContent #= HTML.create_H1("API Root Page", null, null);
        headerContent #= HTML.create_Div("The landing page for Flight Data", null, null);
        // Main
        var mainContent : Text = "";
        mainContent #= HTML.create_H1("Links:", null, null);
        // Link to collection page
        mainContent #= HTML.create_H2("Collections Page", null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Collections HTML", "/collections", null, null),null,null);
        mainContent #= HTML.create_Div("The Listing of all available Feature Collections - as HTML",null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Collections JSON", "/collections?f=JSON", null, null),null,null);
        mainContent #= HTML.create_Div("The Listing of all available Feature Collections - JSON for GIS applications",null, null);       

        // Link to the landing page
        mainContent #= HTML.create_H2("Landing Page", null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Home HTML", "/", null, ?"current"),null,null);
        mainContent #= HTML.create_Div("This Page - The landing page as HTML",null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Home JSON", "/?f=JSON", null, ?"current"),null,null);
        mainContent #= HTML.create_Div("The landing page as JSON. The same content as this page but useful for GIS Clients",null, null);
        // Link to the API Page
        // TODO define the pages
        mainContent #= HTML.create_H2("API Description", null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("API HTML", "/api", null, null),null,null);
        mainContent #= HTML.create_Div("The documentation of the interfaces as html (currently not implemented)",null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("API JSON", "/api?f=JSON", null, null),null,null);
        mainContent #= HTML.create_Div("The documentation of the interfaces as json - swagger file (currently not implemented)",null, null);
        // Link to the Conformance Page
        // TODO define the pages
        mainContent #= HTML.create_H2("Conformance Classes", null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Conformance HTML", "/conformance", null, null),null,null);
        mainContent #= HTML.create_Div("The conformance classes according to OGC (currently not implemented)",null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Conformance JSON", "/conformance?f=JSON", null, null),null,null);
        mainContent #= HTML.create_Div("The conformance classes according to OGC as JSON (currently not implemented)",null, null);


        // Footer
        var footerContent : Text = "";
        footerContent #= HTML.create_Div("Test for OGC on IC", null, null);
        
        // Body
        var body :Text = "";
        body #= HTML.create_Header(headerContent, null, null);
        body #= HTML.create_Main(mainContent, null, null);
        body #= HTML.create_Footer(footerContent, null, null);
    	
        
        return HTML.createPage(?head,?body);
    };
};