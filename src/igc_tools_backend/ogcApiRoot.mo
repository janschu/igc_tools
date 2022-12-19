import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";
import JH "jsonHelper";
import HTML "html_helper";


module {


    public func getRootPage (map: TM.TrackMap, baseURL: Text, repr: H.Representation ): Text {
        if (repr == #json) {
            return getRootJSON(map,baseURL);
        };
        return getRootHTML(map,baseURL);
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
        // Head
        // empty
        // Body
        var body :Text = HTML.createTag("b",?"not implemented", null);
        body #= HTML.create_A("Hallo","http://www.yahoo.de",null,?"testclass");
        return HTML.createPage(null,?body);
    };
};