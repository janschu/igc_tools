import I "mo:base/Iter";
import H "helper";
import F "mo:base/Float";
import C "mo:base/Char";


module {
    
    private func textOrNull (text : ?Text) : Text {
        switch (text) {
            case (null) {
                return "null";
            };
            case (?t) {
                return "\""#t#"\"";
            };
        };
    };
    
    // return a kvp if not null
    public func optKvpJSON (key: Text, value: ?Text, comma: Bool) : Text {
        switch (value) {
            case (null) {
                return "";
            };
            case (?val) {
                return kvpJSON(key, val, comma);
            };
        };
    };
    
    // return a kvp
    public func kvpJSON (key:Text, value:Text, comma:Bool) : Text {
        var text : Text = "\"" # key # "\": " # "\"" # value # "\"";
        if (comma) {
            text #= ",";
        };
        text #= lb();
        return text; 
    };

    // return an array of Text Items
    public func textArrayJSON (texts: [Text]) : Text {
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

    // generate a Link as used at OGC API
    public func linkJSON (rel: Text, typ: Text, title: Text, href: Text) : Text {
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

    // used for pretty print during dev
    public func lb () : Text {
        // let cr : Char = C.fromNat32(0x000D);
        // C.toText(cr);
        " "; 
    };

    public func spatialExtentJson (bbox : H.BBox) : Text {
        var text : Text = "\"spatial\": {";
        text #= "\"bbox\": [ ["; // why 2 brackets?
        text #= F.toText(bbox.minLon) # ", " # F.toText(bbox.minLat) #", " # F.toText(bbox.maxLon) # ", " # F.toText(bbox.maxLat); 
        text #= "] ]";
        text #="}";
        return text;
    };

    public func temporalExtentJson (start: ?Text, end: ?Text) : Text {
        var text : Text = "\"temporal\": {";
        text #= "\"interval\": [ ["; // why 2 brackets?
        text #= textOrNull(start) # "," # textOrNull(end);
        text #= "] ]";
        text #="}";
        return text;
    };   
};