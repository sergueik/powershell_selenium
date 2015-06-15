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
