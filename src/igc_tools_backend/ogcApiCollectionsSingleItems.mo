import F "mo:base/Float";

import TM "igcTrackMap";
import TR "igcTrack";
import OC "ogcApiCollections";
import H "helper";
import DT "dateTime";
import HTML "htmlHelper";


module {

    // The Items of the complete map
    public func getCollectionsSingleMapItems (map: TM.TrackMap, baseURL: Text, repr: H.Representation ): Text {
        if (repr == #json) {
            return getCollectionsSingleMapItemsJSON(map,baseURL);
        };
        return getCollectionsSingleMapItemsHTML(map,baseURL);
    };

    private func getCollectionsSingleMapItemsJSON (map: TM.TrackMap, baseURL: Text) : Text {
        return map.getGeoJSONLineCollection ();
    };

    private func getCollectionsSingleMapItemsHTML (map: TM.TrackMap, baseURL: Text) : Text {
        return htmlSkeletonCollection(map.getGeoJSONLineCollection (), map.getBBox(), "FC");       
    };

    // The Items of a single Track
    
    public func getCollectionsSingleTrackItems (track: TR.Track, baseURL: Text, repr: H.Representation ): Text {
        if (repr == #json) {
            return getCollectionsSingleTrackItemsJSON(track,baseURL);
        };
        return getCollectionsSingleTrackItemsHTML(track,baseURL);
    };

    private func getCollectionsSingleTrackItemsJSON (track: TR.Track, baseURL: Text) : Text {
        track.getGeoJSONPointCollection();
    };

    private func getCollectionsSingleTrackItemsHTML (track: TR.Track, baseURL: Text) : Text {
        return htmlSkeletonCollection(track.getGeoJSONPointCollectionChunk(0,10), track.getBBox(), track.getTrackId());
    };

    // Helper for HTML Skeleton
    // Genetates the page with a JSON and the ID
    private func htmlSkeletonCollection (geoJSON: Text, extent: H.BBox, collectionID : Text) : Text {
       // head
        var head : Text = HTML.create_MetaCharset("utf-8");
        head #= HTML.create_MetaNameContent("viewport","width=device-width, initial-scale=1" );
        head #= HTML.create_Link("stylesheet", "https://cdn.simplecss.org/simple.min.css");
        // Leaflet
        head #= HTML.create_Link("stylesheet", "https://unpkg.com/leaflet@1.9.2/dist/leaflet.css"); // integrity and crossorigin?
        head #= HTML.create_Script(null,?"https://unpkg.com/leaflet@1.9.2/dist/leaflet.js");
        // Init Leaflet - this is ugly
        var mapScript : Text = "function initMap(event){";
        mapScript #= "var flightMap = L.map('FlightMap');";
        mapScript #= "flightMap.setView([53.04229, 8.6335013],10, );";
        mapScript #= "flightMap.fitBounds([[" # F.toText(extent.minLat) # ", " # F.toText(extent.minLon) # "], [" # F.toText(extent.maxLat) # "," # F.toText(extent.maxLon) # "]]);";
        mapScript #= "var topPlusLayer = L.tileLayer.wms('http://sgx.geodatenzentrum.de/wms_topplus_open?',";
        mapScript #= " {format: 'image/png', layers: 'web',";
        mapScript #= " attribution: '&copy; Bundesamt f&uuml;r Kartographie und Geod&auml;sie 2019'});";
        mapScript #= " topPlusLayer.addTo(flightMap);";

        // Get the flights
        mapScript #= "var flightFeatures = ";
        mapScript #= geoJSON # ";";
        //mapScript #= getBBoxJSONFeature(extent) # ";";
        mapScript #= "L.geoJSON(flightFeatures).addTo(flightMap);";

        mapScript #= "};";
        mapScript #= "document.addEventListener('DOMContentLoaded', initMap);";

        head #= HTML.create_Script(?mapScript,null);
        // Style Setting just for the map
        var mapStyle : Text = "div#FlightMap { min-height: 500px;}";
        head #= HTML.create_Style(mapStyle);

        // body
        // - - Header Parts
        var headerContent :Text = "";
        // - - - Nav
        var navContent : Text = "";
        navContent #= HTML.create_A("Landing", "/", null, null);
        navContent #= HTML.create_A("Collections", "/collections", null, null);
        navContent #= HTML.create_A(collectionID, "/collections/" # collectionID, null, null);
        navContent #= HTML.create_A("Items", "/collections/" # collectionID # "/items", null, ?"current");
        navContent #= HTML.create_A("Service Description", "https://m2ifq-raaaa-aaaah-abtla-cai.ic0.app/openapi.html", null, null);
        navContent #= HTML.create_A("Conformance", "/conformance", null, null);
        navContent #= HTML.create_A("JSON", "/collections/" # collectionID # "/items?f=JSON", null, ?"JSON");
        // - - Header
        headerContent #= HTML.create_Nav(navContent,null,null);
        headerContent #= HTML.create_H1("Data Page for Feature Collection", null, null);
        headerContent #= HTML.create_Div("All Flights in one Feature Collection", null, null);
         // Main
        var mainContent : Text = "";
        mainContent #= HTML.create_H1("Spatial Extent", null, null);

        mainContent #= HTML.create_Div("", ?"FlightMap", null);

        // Main
        mainContent #= HTML.create_H1("Links:", null, null);
        // Link to collection page
        mainContent #= HTML.create_H2("Items Page", null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Items HTML", "/collections/" # collectionID # "/items", null, null),null,null);
        mainContent #= HTML.create_Div("Data for the Feature Collection - as HTML",null, null);
        mainContent #= HTML.create_H3(
            HTML.create_A("Items JSON", "/collections/" # collectionID # "/items?f=JSON", null, null),null,null);
        mainContent #= HTML.create_Div("Data for the Feature Collection - JSON for GIS applications",null, null);  

        // all flights as one collection
        // a dummy JSON
        


        // Footer
        var footerContent : Text = "";
        footerContent #= HTML.create_Div("Test for OGC on IC", null, null);
        
        // Body
        var body :Text = "";
        body #= HTML.create_Header(headerContent, null, null);
        body #= HTML.create_Main(mainContent, null, null);
        body #= HTML.create_Footer(footerContent, null, null);
        
        return HTML.createPage(?head,?body);        
    };    

    public func getBBoxJSONFeature (box : H.BBox) : Text {
        var jsonFeature : Text = "{\"type\": \"Feature\", \"properties\": {";
        jsonFeature #= "}, \"geometry\": ";
        jsonFeature #= "{\"coordinates\": [";
        jsonFeature #= "[";
        jsonFeature #= "[" # F.toText(box.minLon) # "," # F.toText(box.minLat) # "]";
        jsonFeature #= ",";
        jsonFeature #= "[" # F.toText(box.minLon) # "," # F.toText(box.maxLat) # "]";
        jsonFeature #= ",";
        jsonFeature #= "[" # F.toText(box.maxLon) # "," # F.toText(box.maxLat) # "]";
        jsonFeature #= ",";
        jsonFeature #= "[" # F.toText(box.maxLon) # "," # F.toText(box.minLat) # "]";
        jsonFeature #= ",";
        jsonFeature #= "[" # F.toText(box.minLon) # "," # F.toText(box.minLat) # "]";
        jsonFeature #= "]";
        jsonFeature #= "], \"type\": \"Polygon\"";
        jsonFeature #= "}";
        jsonFeature #= "}";

        return jsonFeature;
    };


};
