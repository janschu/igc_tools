import H "helper";
import JH "jsonHelper";
import HTML "htmlHelper";


module {
    public func getConformancePage (repr: H.Representation ): Text {
        if (repr == #json) {
            return getConformancePageJSON();
        };
        return getConformancePageHTML();
    };

    
    // {
    //   "conformsTo": [
    //     "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core",
    //     "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30",
    //     "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html",
    //     "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson"
    //   ]
    // }
    private func getConformancePageJSON () : Text {
        // Open
        var text : Text = "{" # JH.lb();
        text #= "\"conformsTo\": ";
        text #= JH.textArrayJSON(["http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core",
        "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30",
        "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html",
        "http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson"
        ]);
        // close 
        text #= "}";
        return text;
    } ;

    private func getConformancePageHTML () : Text {  
         // - Head
        var head : Text = HTML.create_MetaCharset("utf-8");
        head #= HTML.create_MetaNameContent("viewport","width=device-width, initial-scale=1" );
        head #= HTML.create_Link("stylesheet", "https://cdn.simplecss.org/simple.min.css");
        
        // - Body Parts

        // - - Header Parts
        var headerContent :Text = "";
        // - - - Nav
        var navContent : Text = "";
        navContent #= HTML.create_A("Landing", "/", null, ?"current");
        navContent #= HTML.create_A("Collections", "/collections", null, null);
        navContent #= HTML.create_A("Service Description", "https://m2ifq-raaaa-aaaah-abtla-cai.ic0.app/openapi.html", null, null);
        navContent #= HTML.create_A("Conformance", "/conformance", null, null);
    
        navContent #= HTML.create_A("JSON", "/conformance?f=JSON", null, ?"JSON");
        // - - Header
        headerContent #= HTML.create_Nav(navContent,null,null);
        headerContent #= HTML.create_H1("Conformances", null, null);
        headerContent #= HTML.create_Div("Conformancesclasses specified by URI", null, null);
        // Main
        
        var confList : Text = "";
        confList #= HTML.create_Li("http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/core",null, null);
        confList #= HTML.create_Li("http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/oas30",null, null);
        confList #= HTML.create_Li("http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/html",null, null);
        confList #= HTML.create_Li("http://www.opengis.net/spec/ogcapi-features-1/1.0/conf/geojson",null, null);

        var mainContent : Text = "";
        mainContent #= HTML.create_Ul(confList, null, null);
        
        // Footer
        var footerContent : Text = "";
        footerContent #= HTML.create_Div("Test for OGC on IC", null, null);
        
        // Body
        var body :Text = "";
        body #= HTML.create_Header(headerContent, null, null);
        body #= HTML.create_Main(mainContent, null, null);
        body #= HTML.create_Footer(footerContent, null, null);
    	
        
        return HTML.createPage(?head,?body);
    } ;
}