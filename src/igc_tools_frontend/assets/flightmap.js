function initMap(event){
	var flightMap = L.map('FlightMap');
	flightMap.setView([53.04229, 8.6335013],10, );

	var topPlusLayer = L.tileLayer.wms('http://sgx.geodatenzentrum.de/wms_topplus_open?', {format: 'image/png', layers: 'web', attribution: '&copy; <a href="http://www.bkg.bund.de">Bundesamt f&uuml;r Kartographie und Geod&auml;sie 2019</a>, <a href=" http://sg.geodatenzentrum.de/web_public/Datenquellen_TopPlus_Open.pdf">Datenquellen</a>'});

	topPlusLayer.addTo(flightMap);
}

document.addEventListener('DOMContentLoaded', initMap);