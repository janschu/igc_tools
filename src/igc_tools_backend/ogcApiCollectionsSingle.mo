import TM "igcTrackMap";
import TR "igcTrack";
import OC "ogcApiCollections";
import H "helper";


module {
    type representation = {#json; #html};

    // The complete Map as FC
    public func getCollectionsSingleMap (map: TM.TrackMap, baseURL: Text, repr: representation ): Text {
        if (repr == #json) {
            return getCollectionsSingleMapJSON(map,baseURL);
        };
        return getCollectionsSingleMapHTML(map,baseURL);
    };

    private func getCollectionsSingleMapJSON (map: TM.TrackMap, baseURL: Text) : Text {
        let mapMetadata : TM.Metadata = map.getMetadata();

        OC.apiJSONText(? mapMetadata.title, ? mapMetadata.description, ? mapMetadata.id, baseURL # "/collections/" # mapMetadata.id, 
                            ["Collection", "Glider", "Flights"], mapMetadata.bbox, 
                            ? H.prettyDateTime(mapMetadata.start), ? H.prettyDateTime(mapMetadata.land), true);
    };

    private func getCollectionsSingleMapHTML (map: TM.TrackMap, baseURL: Text) : Text {
        "HTML not implemented";
    };


    public func getCollectionsSingleTrack (track: TR.Track, baseURL: Text, repr: representation ): Text {
        if (repr == #json) {
            return getCollectionsSingleTrackJSON(track,baseURL);
        };
        return getCollectionsSingleTrackHTML(track,baseURL);
    };

    private func getCollectionsSingleTrackJSON (track: TR.Track, baseURL: Text) : Text {
        OC.apiJSONTrack(track,baseURL); 
    };

    private func getCollectionsSingleTrackHTML (track: TR.Track, baseURL: Text) : Text {
        "HTML not implemented";
    };

};
