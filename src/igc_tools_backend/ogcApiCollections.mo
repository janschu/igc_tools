import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";
import JH "jsonHelper";
import DT "dateTime";

module {
    type representation = {#json; #html};

    public func getCollectionsPage (map: TM.TrackMap, baseURL: Text, repr: representation ): Text {
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
        "HTML not implemented";
    };

    public func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # "Glider : " # H.optionalText(metadata.gliderId) # "Start: " # H.optionalText(metadata.start)),
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


};