import { igc_tools_backend } from "../../declarations/igc_tools_backend";

// The relevant html elements
const uploadForm = document.getElementById("uploadForm")
const inputFileSelector = document.getElementById("inputFile");
const submitButton = document.getElementById("submitButton");
const messageBox = document.getElementById("message");
const debugBox = document.getElementById("debug");
const FileListElement = document.getElementById("fileId");
var text = "";
var flightMap;
var flightOverlay;

// Handler on file input box 
// Reading a text file
// write content into debug box
function handleFiles() {
  submitButton.setAttribute("disabled", true);
  var file = this.files[0]; 
  let reader = new FileReader();
  text = reader;
  reader.readAsText(file);

  // display the file text in debug box
  reader.onload = function() {
    text = reader.result;
    debugBox.innerText = text;
  };
  // Error handling
  reader.onerror = function() {
    debugBox.innerText = reader.error;
    console.log(reader.error);
  };

  submitButton.removeAttribute("disabled");
}

// Call the Main.mo
async function uploadIGC (event) {
  event.preventDefault();
  
  submitButton.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const message = await igc_tools_backend.uploadIGC(text);

  submitButton.removeAttribute("disabled");

  messageBox.innerText = message;

  getTracklist(event);

}

async function getTrackAsLine(event){
  var source = event.target || event.srcElement;
  // remove the old layer first
  if (flightOverlay) {
    flightMap.removeLayer(flightOverlay);
  }
  const geojson = await igc_tools_backend.getTrackLineGeoJSON(source.name);
  messageBox.innerText = geojson; 
  var geoJSONFeature = JSON.parse(geojson);
  flightOverlay = L.geoJson(geoJSONFeature);
  flightMap.addLayer(flightOverlay);
  flightMap.fitBounds(flightOverlay.getBounds());  
};

// Call Main.mo getTracklist
async function getTracklist(event) {
  const tracklist = await igc_tools_backend.getTrackList();
  FileListElement.replaceChildren();
  for (const track of tracklist){
    const button = document.createElement("button");
    button.setAttribute("type", "button");
    button.setAttribute("class", "list-group-item list-group-item-action rounded");
    button.setAttribute("name", track.trackId);
    const subheading = document.createElement("div");
    subheading.setAttribute("class", "fw-bold");
    const subheadingText = document.createTextNode(track.gliderId);
    subheading.appendChild(subheadingText);
    button.appendChild(subheading);
    const buttonText = document.createTextNode(track.start + " - " + track.land);
    button.appendChild(buttonText);
    button.addEventListener("click",getTrackAsLine);
    FileListElement.appendChild(button);
  }
};

function initMap(event){
	flightMap = L.map('FlightMap');
	flightMap.setView([53.04229, 8.6335013],8, );

	var topPlusLayer = L.tileLayer.wms('http://sgx.geodatenzentrum.de/wms_topplus_open?', {format: 'image/png', layers: 'web', attribution: '&copy; <a href="http://www.bkg.bund.de">Bundesamt f&uuml;r Kartographie und Geod&auml;sie 2019</a>, <a href=" http://sg.geodatenzentrum.de/web_public/Datenquellen_TopPlus_Open.pdf">Datenquellen</a>'});

	topPlusLayer.addTo(flightMap);
}

inputFileSelector.addEventListener("change", handleFiles, false);
uploadForm.addEventListener("submit", uploadIGC);
document.addEventListener('DOMContentLoaded', initMap);
document.addEventListener('DOMContentLoaded', getTracklist);