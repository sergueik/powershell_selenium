using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net;
using System.Threading.Tasks;
using Splunk.Client;
using System.IO;
public class Program
{
	
	private static string user = "admin";
	private static string password = 	"sample_password" ;
	private static string index_name = "test";
	
	private static IService splunk_service_client;
	private static ITransmitter transmitter;
	private static TransmitterArgs transmitter_args;

	// https://github.com/codereflection/FiddlerToSplunk
	// http://dev.splunk.com/view/csharp-sdk-pcl/SP-CAAAEZB
    public static void Main()
    {
    	   ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
        // Create new Service object
        splunk_service_client = new Splunk.Client.Service(Splunk.Client.Scheme.Https, "localhost", 8089,new Namespace(user: user, app: "search"));
        // define transmitter args  
        transmitter_args = new TransmitterArgs { Host = "localhost", Source = "eventlog", SourceType = "JSON" };

        // connect
        splunk_login(user, password).Wait();
        // Print received Session Key to verify login
        Console.Error.WriteLine(String.Format("Host: {0}\r\nPort: {1}\r\nSession Key: '{2}'" , 
                                               splunk_service_client.Context.Host,
                                               splunk_service_client.Context.Port,
                                               splunk_service_client.Context.SessionKey));

        splunk_assert_index_present(index_name).Wait();
        transmitter = splunk_service_client.Transmitter;
        // TODO : uploads 
        splunk_logoff().Wait();
    }
    static async Task splunk_login(string username, string password){
    	await splunk_service_client.LogOnAsync(username, password);
    }
    static async Task splunk_upload(string data, string index_name){

            await transmitter.SendAsync(data, index_name, transmitter_args);
        }
    
    static async Task splunk_logoff(){
            Console.Write(".");            
            await splunk_service_client.LogOffAsync();
        }
   
      static async Task splunk_assert_index_present(string index_name)
        {
          	var index_handle = await splunk_service_client.Indexes.GetOrNullAsync(index_name);
            if (index_handle == null || index_handle.Disabled)
            {
            	throw new Exception("invalid or diabled index: " + index_name);
            }
                   
          }

}
/*
namespace FiddlerToSplunk
{
    class Program
    {
        const string IndexName = "fiddler-index";
        static bool _quitRequested;
        static Service _service;
        static Index _index;
        static TransmitterArgs _args;
        static Transmitter _transmitter;

        static void Main()
        {
            ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;

            FiddlerApplication.SetAppDisplayName("FiddlerToSplunk");
            FiddlerApplication.OnNotification += OnNotification;
            FiddlerApplication.Log.OnLogString += OnLogString;
            FiddlerApplication.AfterSessionComplete += SessionComplete;

            _service = new Service(Scheme.Https, "localhost", 8089, new Namespace(user: "nobody", app: "search"));
_
            _args = new TransmitterArgs { Host = "localhost", Source = "FiddlerToSplunk", SourceType = "JSON" };

            SplunkSetup("admin", "changeme").Wait();

            FiddlerApplication.Startup(8877, true, false, true);

            MainFeedbackLoop();

            FiddlerApplication.Shutdown();
        }

        static async Task SplunkSetup(string username, string password)
        {
            await _service.LoginAsync(username, password);
            _index = await _service.Indexes.GetOrNullAsync(IndexName);
            if (_index != null)
            {
                await _index.RemoveAsync();
            }
            _index = await _service.Indexes.CreateAsync(IndexName);
            await _index.EnableAsync();
            _transmitter = _service.Transmitter;
        }

        static async Task SendToSplunk(string data)
        {
            Console.Write(".");
            await _transmitter.SendAsync(data, IndexName, _args);
        }

        static void SessionComplete(Session s)
        {
            if (s.hostname.Equals("localhost", StringComparison.InvariantCultureIgnoreCase) || 
                s.hostname.Equals(Environment.MachineName, StringComparison.InvariantCultureIgnoreCase))
                return;

            var strippedDownSession = new
            {
                s.bHasResponse,
                s.bHasWebSocketMessages,
                s.bypassGateway,
                s.clientIP,
                s.clientPort,
                s.fullUrl,
                s.host,
                s.hostname,
                s.id,
                s.isFTP,
                s.isHTTPS,
                s.isTunnel,
                s.LocalProcessID,
                s.PathAndQuery,
                s.port,
                s.RequestMethod,
                s.responseCode,
                s.SuggestedFilename,
                s.Tag,
                s.TunnelEgressByteCount,
                s.TunnelIngressByteCount,
                s.TunnelIsOpen,
                s.url,
                RequestHeaders = s.oRequest.headers.ToDictionary(),
                ResponseHeaders = s.oResponse.headers.ToDictionary()
            };
            var data = JsonSerializer.SerializeToString(strippedDownSession);
            SendToSplunk(data).Wait();
        }

        static void MainFeedbackLoop()
        {
            Console.WriteLine("Application running, press q to quit");
            while (!_quitRequested)
            {
                try
                {
                    var keyValue = Console.ReadKey(true).KeyChar.ToString(CultureInfo.InvariantCulture).ToLower();

                    if (keyValue == "q")
                    {
                        _quitRequested = true;
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine("Error: {0}", e);
                }
            }
        }

        static void OnLogString(object sender, LogEventArgs logEventArgs)
        {
            Console.WriteLine("LogOnOnLogString: {0}", logEventArgs.LogString);
        }

        static void OnNotification(object sender, NotificationEventArgs e)
        {
            Console.WriteLine("OnNotification: {0}", e.NotifyString);
        }
    }

    public static class FiddlerExtensions
    {
        public static Dictionary<string, string> ToDictionary(this HTTPHeaders headers)
        {
            if (headers == null) return null;

            var result = new Dictionary<string, string>();

            foreach (var item in headers.ToArray())
            {
                if (!result.ContainsKey(item.Name))
                    result.Add(item.Name, item.Value);
                else
                    result[item.Name] += ";" + item.Value;
            }

            return result;
        }
    }
}

*/
