import Text "mo:base/Text";

actor {
  type HeaderField = (Text, Text);

  type Token = {};

  type StreamingCallbackHttpResponse = {
    body : Blob;
    token : Token;
  };

  type StreamingStrategy = {
    #Callback : {
      callback : shared Token -> async StreamingCallbackHttpResponse;
      token : Token;
    };
  };

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
    streaming_strategy : ?StreamingStrategy;
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    {
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("Response to " # request.method # " request (query)");
      streaming_strategy = null;
    };
  };

  public shared func http_request_update(request : HttpRequest) : async HttpResponse {
    {
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("Response to " # request.method # " request (update)");
      streaming_strategy = null;
    };
  };
};