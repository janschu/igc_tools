import L "mo:base/List";
import I "mo:base/Iter";

module {
    public type attribute = {attname: Text; attval: Text}; 

    /// Open a simple Tag
    public func openSimpleTag (name: Text): Text {
        openTag(name, null);
    };
    
    /// Open a Tag with attributes
    public func openTag (name: Text, attributes: ?L.List <attribute>) : Text {
        var tag = "<";
        tag #=name;
        switch (attributes){
            case null {};
            case (? list) {
                let iter : I.Iter<attribute> = L.toIter<attribute>(list);
                for (att in iter) {
                    tag #=" " # att.attname;
                    tag #="=\"" # att.attval #"\"";    
                }
            };
        };
        tag #=">";
        return tag;
    };

    /// Close a Tag
    public func closeTag (name: Text) : Text {
        "</" # name # ">";
    };

    /// Create a Tag with content and attributes
    public func createTag (name: Text, content: ?Text, attributes: ?L.List <attribute>): Text {
        var tag = openTag(name, attributes);
        switch (content){
            case null {};
            case (? text) {
                tag #= text;
            };
        };
        tag #= closeTag(name);
        return tag;
    };

    // the content Tags include an optional id and an optional class #
    public func createContentTag (name: Text, content: ?Text, attributes:?L.List<attribute>, id: ?Text, cssClass: ?Text) : Text {
        var attList : L.List<attribute> = L.nil<attribute>();
        switch(attributes) {
            case(null) {  };
            case(? aList) {
                attList := L.append <attribute> (attList, aList);
             };
        };
        switch(id) {
            case(null) {  };
            case(? text) {
                attList := L.push({attname = "id"; attval = text}, attList);
             };
        };
        switch(cssClass) {
            case(null) {  };
            case(? text) {
                attList := L.push({attname = "class"; attval = text;}, attList);
             };
        };
        if(L.size(attList)==0) {
            return createTag(name, content, null);
        } else {
            return createTag(name, content, ?attList);
        };
    };

    /// Create a head Tag
    public func createHeadTag(content: ?Text) : Text {
        return createTag("head", content, null);
    };

    /// Create a body Tag
    public func createBodyTag(content: ?Text) : Text {
        return createTag("body", content, null);
    };

    /// Create a HTML Page
    public func createPage(headerContent: ?Text, bodyContent: ?Text) : Text {
        var doc : Text = "<!DOCTYPE html>";
        doc #= createHeadTag(headerContent);
        doc #= createBodyTag(bodyContent);
        return doc;
    };


    /// Create a Link
    public func create_A (bodyContent: Text, href: Text, id : ?Text, cssClass : ?Text) : Text {
        var att : L.List <attribute> = L.fromArray<attribute>([{attname = "href"; attval = href;}]);
        return createContentTag("a", ?bodyContent, ?att, id, cssClass);
    };

    /// Create a div
    public func create_Div (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("div", ?bodyContent, null, id, cssClass);
    };

    /// Create a Heading H1
    public func create_H1 (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("H1", ?bodyContent, null, id, cssClass);
    };

    /// Create a Heading H2
    public func create_H2 (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("H2", ?bodyContent, null, id, cssClass);
    };

    /// Create a Heading H3
    public func create_H3 (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("H3", ?bodyContent, null, id, cssClass);
    };

    /// Create a LIst Item
    // Todo: Do we need attributes?
    public func create_Li (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("li", ?bodyContent, null, id, cssClass);
    };

    /// Create an Unsorted List
    // Todo: Do we need attributes?
     public func create_Ul (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("ul", ?bodyContent, null, id, cssClass);
    };  
    
     
    
}