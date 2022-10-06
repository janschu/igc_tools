import { igc_tools_backend } from "../../declarations/igc_tools_backend";

// The relevant html elements
const uploadForm = document.getElementById("uploadForm")
const inputFileSelector = document.getElementById("inputFile");
const submitButton = document.getElementById("submitButton");
const messageBox = document.getElementById("message");
const debugBox = document.getElementById("debug");
var text = "";

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

}

inputFileSelector.addEventListener("change", handleFiles, false);
uploadForm.addEventListener("submit", uploadIGC);