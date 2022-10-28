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

    private func lb () : Text {
        let cr : Char = C.fromNat32(0x000D);
        //let nl : Char = C.fromNat32(0x000A);
        C.toText(cr); 
    };

    private func optKvpJSON (key:Text, value: ?Text, comma:Bool) : Text {
        switch (value) {
            case (null) {
                return "";
            };
            case (?val) {
                return kvpJSON(key, val, comma);
            };
        };
    };
    
    
    private func kvpJSON (key:Text, value:Text, comma:Bool) : Text {
        var text : Text = "\"" # key # "\": " # "\"" # value # "\"";
        if (comma) {
            text #= ",";
        };
        text #= lb();
        return text; 
    };

    private func linkJSON (rel: Text, typ: Text, title: Text, href: Text) : Text {
        // open
        var text : Text = "{" # lb();
        text #= kvpJSON("rel",rel,true);
        text #= kvpJSON("type",typ,true);
        text #= kvpJSON("title",title,true);
        text #= kvpJSON("href",href,false);
        // close 
        text #= "}";
        return text;
    };

    private func textArrayJSON (texts: [Text]) : Text {
        var text : Text = "[";
        let iterator : I.Iter<Text> = I.fromArray(texts);
        I.iterate<Text>(iterator, func (i, _index) {
            text #= "\"" # i # "\"";
            if (_index+1 < texts.size()){
                text #=",";
            };
        });
        text #= "]";
        return text;       
    };

    
    private func apiJSONTrack (track : TR.Track, baseURL: Text) : Text {
        let metadata : TR.Metadata = track.getMetadata();
        apiJSONText (
            ? ("Flight: " # H.optionalText(metadata.gliderId) # " " # H.optionalText(metadata.start)),
            ? ("FlightLog: " # lb() # "Glider : " # H.optionalText(metadata.gliderId) # lb() # "Start: " # H.optionalText(metadata.start)),
            ? metadata.trackId,
            ? (baseURL # "/" # metadata.trackId),
            ["Flight", "Track", H.optionalText(metadata.gliderId), H.optionalText(metadata.gliderPilot), H.optionalText(metadata.competitionId)],
            true
        );
    };
    
    private func apiJSONText (title: ?Text, description: ?Text, id: ?Text, landingPage: ?Text, tags: [Text], isDataset: Bool) : Text {
        // Open
        var text : Text = "{" # lb();
        text #= optKvpJSON("title",title,true);
        text #= optKvpJSON("description",description,true);
        text #= optKvpJSON("id",id,true);
        text #= optKvpJSON("landingPageUri",landingPage,true);
        text #= kvpJSON("tags",textArrayJSON(tags),true);
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
        var body : Text = "{" # lb();
        // Metadata
        body #= kvpJSON("title", map.getMetadata().title, true);
        body #= kvpJSON("description", map.getMetadata().description, true);
        // Links
        body #= "\"links\": " # "[" # lb();
        body #=linkJSON("self", "application/json", "This document as JSON", baseURL#"?f=json");
        body #=","#lb();
        body #=linkJSON("alternate", "text/html", "This document as HTML", baseURL#"?f=html");
        body #= "],"#lb();
        // catalog
        body #= kvpJSON("catalogUri", baseURL,true);
        // apis
        body #= "\"apis\": [" # lb();
        // Loop all Tracks as single API Entriepoints

        let iterTracks : I.Iter<TR.Track> = map.tracks.vals();
        I.iterate<TR.Track>(iterTracks, func(track, _index) {
            body #= apiJSONTrack(track,baseURL);
            if (_index+1 < map.tracks.size()){
                body #= ",";
            };
            body #= lb();
        });

        body #= "]" # lb();
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