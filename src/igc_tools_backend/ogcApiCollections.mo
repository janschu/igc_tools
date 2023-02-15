import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";
import JH "jsonHelper";
import DT "dateTime";
import HTML "htmlHelper";

module {

    public func getCollectionsPage (map: TM.TrackMap, baseURL: Text, repr: H.Representation ): Text {
        if (repr == #json) {
            return getCollectionsJSON(map,baseURL);
        };
        return getCollectionsHTML(map,baseURL);
    };

    
// {
//   "links": [
//     { "href": "http://data.example.org/collections.json",
//       "rel": "self", "type": "application/json", "title": "this document" },
//     { "href": "http://data.example.org/collections.html",
//       "rel": "alternate", "type": "text/html", "title": "this document as HTML" },
//     { "href": "http://schemas.example.org/1.0/buildings.xsd",
//       "rel": "describedBy", "type": "application/xml", "title": "GML application schema for Acme Corporation building data" },
//     { "href": "http://download.example.org/buildings.gpkg",
//       "rel": "enclosure", "type": "application/geopackage+sqlite3", "title": "Bulk download (GeoPackage)", "length": 472546 }
//   ],
//   "collections": [
//     {
//       "id": "buildings",
//       "title": "Buildings",
//       "description": "Buildings in the city of Bonn.",
//       "extent": {
//         "spatial": {
//           "bbox": [ [ 7.01, 50.63, 7.22, 50.78 ] ]
//         },
//         "temporal": {
//           "interval": [ [ "2010-02-15T12:34:56Z", null ] ]
//         }
//       },
//       "links": [
//         { "href": "http://data.example.org/collections/buildings/items",
//           "rel": "items", "type": "application/geo+json",
//           "title": "Buildings" },
//         { "href": "https://creativecommons.org/publicdomain/zero/1.0/",
//           "rel": "license", "type": "text/html",
//           "title": "CC0-1.0" },
//         { "href": "https://creativecommons.org/publicdomain/zero/1.0/rdf",
//           "rel": "license", "type": "application/rdf+xml",
//           "title": "CC0-1.0" }
//       ]
//     }
//   ]
// }   
    private func getCollectionsJSON (map: TM.TrackMap, baseURL: Text) : Text {
        // Open
        var body : Text = "{" # JH.lb();
        // Links
        body #= "\"links\": " # "[" # JH.lb();
        body #=JH.linkJSON("self", "application/json", "This document as JSON", baseURL#"/collections?f=json");
        body #=","#JH.lb();
        body #=JH.linkJSON("alternate", "text/html", "This document as HTML", baseURL#"/collections?f=html");
        body #= "]"# JH.lb();
        body #=","#JH.lb(); 
        body #= "\"collections\": ["# JH.lb();
        // all tracks as one FC
        // let mapMetadata : TM.Metadata = map.getMetadata();

        // body #= apiJSONText(? mapMetadata.title, ? mapMetadata.description, ? mapMetadata.id, baseURL # "/collections/" # mapMetadata.id, 
        //                   ["Collection", "Glider", "Flights"], mapMetadata.bbox, 
        //                   ? DT.prettyDateTime(mapMetadata.start), ? DT.prettyDateTime(mapMetadata.land), true);
        
        body #= apiJSONText(? map.metadata.title, ? map.metadata.description, ? map.metadata.id, baseURL # "/collections/" # map.metadata.id, 
                            ["Collection", "Glider", "Flights"], map.metadata.bbox, 
                            ? DT.prettyDateTime(map.metadata.start), ? DT.prettyDateTime(map.metadata.land), true);

        body #= ","# JH.lb();

        // each Track as Point FC
        // each Track as Line FC
        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            body #= apiJSONTrack(track,baseURL);
            if (_index+1 < map.tracks.size()){
                body #= ",";
            };
            body #= JH.lb();
        });

        body #= "]"# JH.lb();
        // Close
        body #= "}";

        return body; 
    };

    private func getCollectionsHTML (map: TM.TrackMap, baseURL: Text) : Text {
        // head
        var head : Text = HTML.create_MetaCharset("utf-8");
        head #= HTML.create_MetaNameContent("viewport","width=device-width, initial-scale=1" );
        head #= HTML.create_Link("stylesheet", "https://cdn.simplecss.org/simple.min.css");

        // body
        // - - Header Parts
        var headerContent :Text = "";
        // - - - Nav
        var navContent : Text = "";
        navContent #= HTML.create_A("JSON", "/?f=JSON", null, null);
        navContent #= HTML.create_A("Home", "/", null, null);
        navContent #= HTML.create_A("Collections", "/collections", null, ?"current");
        // - - Header
        headerContent #= HTML.create_Nav(navContent,null,null);
        headerContent #= HTML.create_H1("API Collection Page", null, null);
        headerContent #= HTML.create_Div("Listing the available data/feature collections", null, null);
         // Main
        var mainContent : Text = "";
        mainContent #= HTML.create_H1("Data", null, null);

        // all flights as one collection
        mainContent #= apiHTMLText(? map.metadata.title, ? "All flights in one collection",  baseURL # "/collections/" # map.metadata.id, ?"all gliders in one collection",  
                            ? DT.prettyDateTime(map.metadata.start), ? DT.prettyDateTime(map.metadata.land), true);
        // each flight        
        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            mainContent #= apiHTMLTrack(track,baseURL);
        });

        // other links
        // mainContent #= HTML.create_H1("Other Links", null, null);
        

        
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

    public func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # "Glider : " # H.optionalText(metadata.gliderId) # " Start: " # H.optionalText(metadata.start)),
            ? metadata.trackId,
            baseURL # "/collections/" # metadata.trackId,
            ["Flight", "Track", H.optionalText(metadata.gliderId), H.optionalText(metadata.gliderPilot), H.optionalText(metadata.competitionId)],
            metadata.bbox,
            metadata.start,
            metadata.land,
            true
        );
    };
    
    public func apiJSONText (title: ?Text, description: ?Text, id: ?Text, currentURL: Text, tags: [Text], boundingBox: H.BBox, start: ?Text, end: ?Text, isDataset: Bool) : Text {
        // Open
        var text : Text = "{" # JH.lb();
        text #= JH.optKvpJSON("title",title,true);
        text #= JH.optKvpJSON("description",description,true);
        text #= JH.optKvpJSON("id",id,true);
        text #= "\"keywords\": " # JH.textArrayJSON(tags) # "," # JH.lb();
        if (isDataset) {
            text #= "\"isDataset\": true";
        }
        else {
            text #= "\"isDataset\": true";
        };
        text #= "," # JH.lb();
        text #= "\"type\": \"FeatureCollection\"";  
        text #= "," # JH.lb();
        text #= "\"extent\": {" #JH.lb();
        text #= JH.spatialExtentJson(boundingBox);
        text #= "," # JH.lb();
        text #= JH.temporalExtentJson(start, end);
        text #= JH.lb();
        text #= "} ," # JH.lb();
        text #= "\"links\": [" # JH.lb();
        text #=JH.linkJSON("items", "application/json", "This document as JSON",currentURL # "?f=json");
        text #=","#JH.lb();
        text #=JH.linkJSON("alternate", "text/html", "This document as HTML", currentURL#"?f=html");
        text #=","#JH.lb();
        text #=JH.linkJSON("items", "application/geo+json", "The items as GeoJSON", currentURL#"/items?f=json");
        text #=","#JH.lb();
        text #=JH.linkJSON("items", "text/html", "The items as HTML", currentURL#"/items?f=html");
        text #= "] " # JH.lb();
        // close 
        text #= "}";
        return text;
    };

    public func apiHTMLTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiHTMLText (
            ? (H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? metadata.trackId,            
            baseURL # "/collections/" # metadata.trackId,
            metadata.gliderId,
            metadata.start,
            metadata.land,
            true
        );
    };

    public func apiHTMLText (title: ?Text,  id: ?Text, currentURL: Text, glider: ?Text, start: ?Text, end: ?Text, isDataset: Bool) : Text {
        // Open
        var text : Text = "";

        var link : Text = "";
        switch (title) {
            case (?t) {link := HTML.create_H2(t, null, null);};
            case (_) {};
        };
        text #= HTML.create_A(link, currentURL, null, null);
        
        var id_div : Text = "";
        switch (id) {
            case(?i) {link := HTML.create_Div("id: " # i # " (html)",null, null) };
            case (_) {};
        };
        id_div #= HTML.create_A(link, HTML.appendURLParam(currentURL, "f", "html"), null, null);

        switch (id) {
            case(?i) {link := HTML.create_Div("id: " # i # " (json)",null, null) };
            case (_) {};
        };
        id_div #= HTML.create_A(link, HTML.appendURLParam(currentURL, "f", "json"), null, null);
        text #= HTML.create_Div(id_div, null, null);

        switch (glider) {
            case(?d) {text #= HTML.create_Div("glider: " # d ,null, null) };
            case (_) {};
        };
        switch (start) {
            case(?s) {text #= HTML.create_Div("start: " # s, null, null) };
            case (_) {};
        };
        switch (end) {
            case(?l) {text #= HTML.create_Div("land: " # l, null, null) };
            case (_) {};
        };
        

        return text;
    };
};