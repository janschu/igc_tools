import C "mo:base/Char";
import I "mo:base/Iter";
import N "mo:base/Nat";

import TM "igcTrackMap";
import TR "igcTrack";
import H "helper";

module {
    type representation = {#json; #html};

    public func getCollectionsPage (map: TM.TrackMap, baseURL: Text, repr: representation ): Text {
        if (repr == #json) {
            return getCollectionsJSON(map,baseURL);
        };
        return getCollectionsHTML(map,baseURL);
    };

    private func getCollectionsJSON (map: TM.TrackMap, baseURL: Text) : Text {
        // Open
        var body : Text = "{" # H.lb();
        body #= "\"collections\": ["# H.lb();

        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            body #= apiJSONTrack(track,baseURL);
            if (_index+1 < map.tracks.size()){
                body #= ",";
            };
            body #= H.lb();
        });

        body #= "]"# H.lb();
        // Close
        body #= "}";

        return body; 
    };

    private func getCollectionsHTML (map: TM.TrackMap, baseURL: Text) : Text {
        "dummy";
    };

    private func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # "Glider : " # H.optionalText(metadata.gliderId) # "Start: " # H.optionalText(metadata.start)),
            ? metadata.trackId,
            baseURL # "/" # metadata.trackId,
            ["Flight", "Track", H.optionalText(metadata.gliderId), H.optionalText(metadata.gliderPilot), H.optionalText(metadata.competitionId)],
            true
        );
    };
    
    private func apiJSONText (title: ?Text, description: ?Text, id: ?Text, currentURL: Text, tags: [Text], isDataset: Bool) : Text {
        // Open
        var text : Text = "{" # H.lb();
        text #= H.optKvpJSON("title",title,true);
        text #= H.optKvpJSON("description",description,true);
        text #= H.optKvpJSON("id",id,true);
        text #= "\"keywords\": " # H.textArrayJSON(tags) # ",";
        if (isDataset) {
            text #= "\"isDataset\": true";
        }
        else {
            text #= "\"isDataset\": true";
        };
        text #= "," # H.lb();
        text #= "\"links\": [" # H.lb();
        text #=H.linkJSON("self", "application/json", "This document as JSON",currentURL # "?f=json");
        text #=","#H.lb();
        text #=H.linkJSON("alternate", "text/html", "This document as HTML", currentURL#"?f=html");
        text #=","#H.lb();
        text #=H.linkJSON("items", "application/geo+json", "The items as GeoJSON", currentURL#"/items?f=json");
        text #=","#H.lb();
        text #=H.linkJSON("items", "text/html", "The items as HTML", currentURL#"/items?f=html");
        text #= "] " # H.lb();
        // close 
        text #= "}";
        return text;
    };


};