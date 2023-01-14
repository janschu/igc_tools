import L "mo:base/List";
import I "mo:base/Iter";
import T "mo:base/Text";

module {
    public type attribute = {attname: Text; attval: Text}; 

    /// Open a simple Tag
    public func openSimpleTag (name: Text, closing: Bool): Text {
        openTag(name, null, closing);
    };
    
    /// Open a Tag with attributes
    public func openTag (name: Text, attributes: ?L.List <attribute>, closing: Bool) : Text {
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
        if (closing) {
            tag #= "/";
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
        var tag : Text = "";
        switch (content){
            case null {
                tag #= openTag(name, attributes, true);
            };
            case (? text) {
                tag #= openTag(name, attributes, false);
                tag #= text;
                tag #= closeTag(name);
            };
        };
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

    // -------------------------------------------------------------------------------------
    // Header Tags
    // -------------------------------------------------------------------------------------
    /// Create a Link Tag
    public func create_Link (rel: Text, href: Text) : Text {
        var att : L.List <attribute> = L.fromArray<attribute>([
            {attname = "rel"; attval = rel},
            {attname = "href"; attval = href;}]);
        return createTag("link", null, ?att);
    };

    /// Create a Script Tag
    public func create_Script (content: ?Text, url : ?Text) : Text {
        // must openb and close the script tag?
        var scriptTag : Text = "";
        switch (url) {
            case (?src) {
                var att :L.List <attribute> = L.fromArray<attribute>([{attname="src";attval=src}]);             
                scriptTag #= openTag("script", ?att, false);
                };
            case (_) {
                scriptTag #= openTag ("script", null, false);};
        };
        switch (content) {
            case (?innerContent) {scriptTag #= innerContent;};
            case (_) {};
        };
        scriptTag #= closeTag("script");
        return scriptTag;
    };

    /// Create a Style Tag
    public func create_Style (style: Text) : Text {
        return createTag("style", ?style, null);
    };   

    /// Create a Meta Name Content
        public func create_MetaNameContent (name: Text, content: Text) : Text {
        var att : L.List <attribute> = L.fromArray<attribute>([
            {attname = "name"; attval = name;},
            {attname = "content"; attval = content;}]);
        return createTag("meta", null, ?att);
    };

    /// Create a Meta Charset
        public func create_MetaCharset (charset: Text) : Text {
        var att : L.List <attribute> = L.fromArray<attribute>([
            {attname = "charset"; attval = charset;}]);
        return createTag("meta", null, ?att);
    };


    // -------------------------------------------------------------------------------------
    // Body Tags
    // -------------------------------------------------------------------------------------
    /// Create a Hyperlink
    public func create_A (bodyContent: Text, href: Text, id : ?Text, cssClass : ?Text) : Text {
        var att : L.List <attribute> = L.fromArray<attribute>([{attname = "href"; attval = href;}]);
        return createContentTag("a", ?bodyContent, ?att, id, cssClass);
    };

    public func appendURLParam (url: Text, key: Text, value: Text) : Text {
        // simply check for ?
        if (T.contains(url, #char('?'))){
            return url # "&" # key # "=" # value;
        } else {
            return url # "?" # key # "=" # value;
        }
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

    /// Create a Quote
    public func create_Q (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("q", ?bodyContent, null, id, cssClass);
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

    /// Create a Header Block
    // Todo: Do we need attributes?
     public func create_Header (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("header", ?bodyContent, null, id, cssClass);
    }; 

    /// Create a Nav Block
    // Todo: Do we need attributes?
     public func create_Nav (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("nav", ?bodyContent, null, id, cssClass);
    }; 
    
    
    /// Create a Main Block
    // Todo: Do we need attributes?
     public func create_Main (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("main", ?bodyContent, null, id, cssClass);
    };

    /// Create a Footer Block
    // Todo: Do we need attributes?
     public func create_Footer (bodyContent: Text, id : ?Text, cssClass : ?Text) : Text {
        return createContentTag("footer", ?bodyContent, null, id, cssClass);
    }; 
    
}