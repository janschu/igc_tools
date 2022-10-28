import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";


module {
    type representation = {#json; #html};

    public func getRootPage (map: TM.TrackMap, baseURL: Text, repr: representation ): Text {
        if (repr == #json) {
            return getRootJSON(map,baseURL);
        };
        return getRootHTML(map,baseURL);
    };


    // TODO Remove - Double with collection
    private func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # H.lb() # "Glider : " # H.optionalText(metadata.gliderId) # H.lb() # "Start: " # H.optionalText(metadata.start)),
            ? metadata.trackId,
            ? (baseURL # "/" # metadata.trackId),
            ["Flight", "Track", H.optionalText(metadata.gliderId), H.optionalText(metadata.gliderPilot), H.optionalText(metadata.competitionId)],
            true
        );
    };
    
    private func apiJSONText (title: ?Text, description: ?Text, id: ?Text, landingPage: ?Text, tags: [Text], isDataset: Bool) : Text {
        // Open
        var text : Text = "{" # H.lb();
        text #= H.optKvpJSON("title",title,true);
        text #= H.optKvpJSON("description",description,true);
        text #= H.optKvpJSON("id",id,true);
        text #= H.optKvpJSON("landingPageUri",landingPage,true);
        text #= "\"tags\":" # H.textArrayJSON(tags) # ",";
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

    private func getRootJSON (map: TM.TrackMap, baseURL: Text) : Text {
        // Open
        var body : Text = "{" # H.lb();
        // Metadata
        body #= H.kvpJSON("title", map.getMetadata().title, true);
        body #= H.kvpJSON("description", map.getMetadata().description, true);

        // catalog
        body #= H.kvpJSON("catalogUri", baseURL,true);
        // Links
        body #= "\"links\": " # "[" # H.lb();
        body #=H.linkJSON("self", "application/json", "This document as JSON", baseURL#"?f=json");
        body #=","#H.lb();
        body #=H.linkJSON("alternate", "text/html", "This document as HTML", baseURL#"?f=html");
        body #=","#H.lb();
        // dummies
        body #=H.linkJSON("service-desc", "application/vnd.oai.openapi+json;version=3.0", "The OpenAPI definition as JSON", "https://api.weather.gc.ca/openapi");
        body #=","#H.lb();
        body #=H.linkJSON("service-doc", "text/html", "The OpenAPI definition as HTML", "https://api.weather.gc.ca/openapi?f=html");
        body #=","#H.lb();
        body #=H.linkJSON("conformance", "application/json",  "Conformance", "https://api.weather.gc.ca/conformance");
        body #=","#H.lb();
        // collections
        body #=H.linkJSON("data", "application/json",  "Collections", baseURL#"/collections");
        body #= "],"#H.lb();
        // apis
        body #= "\"apis\": [" # H.lb();
        // // Loop all Tracks as single API Entriepoints

        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            body #= apiJSONTrack(track,baseURL);
            if (_index+1 < map.tracks.size()){
                body #= ",";
            };
            body #= H.lb();
        });

        body #= "]" # H.lb();
        // Close
        body #= "}";

        return body; 
    };

    private func getRootHTML (map: TM.TrackMap, baseURL: Text) : Text {
        // Open
        var doc : Text = "<!DOCTYPE html>";
        doc #= "<html>";
            doc #= "<head>";
            doc #= "</head>";

            doc #= "<body>";
                doc #= "<b>";
                doc #= "Not implemented";
                doc #= "</b>";
            doc #= "</body>";
        doc #= "</html>";
        return doc; 
    };
};