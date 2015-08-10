
using System;
using System.Text;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
// using Microsoft.Build.BuildEngine;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

using System.Net;
namespace CustomTask  {


class  FormPoster  : Task {

              private string FmyProperty;

              static bool DEBUG = true;
              public static bool Debug {  get { return DEBUG; } set { DEBUG = value; }}

              WebClient myWebClient ;
              string uriString = @"http://ftlplanb02/planb/result.pl" ; 

              [Required]

              public string MyProperty {

                 get { return FmyProperty; }
                 set { FmyProperty = value; }
              }

              public override bool Execute() { 


             // Console.WriteLine(this.BuildEngine.ToString());
              myWebClient = new WebClient();


    // Create a new NameValueCollection instance to hold some custom parameters to be posted to the URL.
    NameValueCollection myNameValueCollection = new NameValueCollection();

    string BuildMachine = System.Environment.GetEnvironmentVariable("COMPUTERNAME");
    string UserName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
    byte[] responseArray = null;


              Console.WriteLine(this.BuildEngine.ProjectFileOfTaskNode.ToString());
              Console.WriteLine(this.MyProperty.ToString());

	      try {

#if DEBUG


             Console.WriteLine("\nUploading to {0} ...", uriString);
             Console.WriteLine("\nMyProperty {0}", MyProperty);

#else

    // Add necessary parameter/value pairs to the name/value container.

        myNameValueCollection.Add("MyProperty", MyProperty );

    try {  
         // Upload the NameValueCollection.    
     //    responseArray =  myWebClient.UploadValues(uriString,"POST",myNameValueCollection);
         // Decode and display the response.
         if (DEBUG ) {
                Console.WriteLine("\nResponse received was:\n{0}",Encoding.ASCII.GetString(responseArray));
         }
    } catch (Exception e) {
       Console.WriteLine (e.ToString());
    }
#endif


                  Console.WriteLine(this.HostObject.ToString());
              } catch (Exception e) {Console.WriteLine(e.ToString());}

              Console.WriteLine("MyTask was passed with property: " + MyProperty);return true;}
    }










  } 

/* 


csc.exe /nologo /r:c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Utilities.dll;c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Microsoft.Build.Framework.dll /t:exe formcustom.cs


*/