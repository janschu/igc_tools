import T "mo:base/Text";
import I "mo:base/Iter";
// local
import OR "../igc_tools_backend/ogcApiRoot";
// dapp
import IGC "canister:igc_tools_backend";
import TM "../igc_tools_backend/igcTrackMap";

actor {  
  
  // all HTTP handling from motoko mailing list
  type HeaderField = (Text, Text);

  type HttpRequest = {
    method : Text;
    url : Text;
    headers : [HeaderField];
    body : Blob;
  };

  type HttpResponse = {
    status_code : Nat16;
    headers : [HeaderField];
    body : Blob;
  };

  // the faster 'query' does not work here
/*   public query func http_request(request : HttpRequest) : async HttpResponse {
    let heads : I.Iter <HeaderField> = request.headers.vals();
    var textBody : Text = "das nervt!";
    {
      status_code = 200;
      headers = [];
      body = T.encodeUtf8(textBody);
    };
  }; */

};