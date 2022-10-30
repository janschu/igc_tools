module {
    public func getCollectionsIndivPage (map: TM.TrackMap, baseURL: Text, repr: representation ): Text {
        if (repr == #json) {
            return getCollectionsIndivJSON(map,baseURL);
        };
        return getCollectionsIndivHTML(map,baseURL);
    };

    private func getCollectionsIndivJSON (, baseURL: Text) : Text {
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
};
