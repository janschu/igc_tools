import H "helper";
import JH "jsonHelper";


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
        "HTML not implemented";    
    } ;
}