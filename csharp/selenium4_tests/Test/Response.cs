using System;
using Fetch = OpenQA.Selenium.DevTools.V109.Fetch;
// alternatively do not add too many aliased imports, 
// but use the class name-prefixed type names like 
// "Fetch.GetResponseBodyCommandResponse" instead of
// "GetResponseBodyCommandResponse"

using GetResponseBodyCommandResponse = OpenQA.Selenium.DevTools.V109.Fetch.GetResponseBodyCommandResponse;
using RequestPausedEventArgs = OpenQA.Selenium.DevTools.V109.Fetch.RequestPausedEventArgs;

// origin: https://github.com/metaljase/SeleniumCaptureHttpResponse/blob/main/Metalhead.SeleniumCaptureHttpResponse.CDP/Response.cs
namespace  Selenium4.Test {
    public class Response {
        public Response(RequestPausedEventArgs requestPausedEventArgs, GetResponseBodyCommandResponse getResponseBodyCommandResponse){
            RequestPausedEventArgs = requestPausedEventArgs;
            GetResponseBodyCommandResponse = getResponseBodyCommandResponse;
        }

        public RequestPausedEventArgs RequestPausedEventArgs { get; set; }
        public GetResponseBodyCommandResponse GetResponseBodyCommandResponse { get; set; }

        public override string ToString() {
            if (GetResponseBodyCommandResponse != null) {
                var body = GetResponseBodyCommandResponse.Body;
                if (GetResponseBodyCommandResponse.Base64Encoded) {
                    body = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(body));
                }
                return body;
            }

            return String.Empty;
        }
    }
}
