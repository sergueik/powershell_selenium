# based on http://www.paraesthesia.com/archive/2009/12/16/posting-multipartform-data-using-.net-webrequest.aspx/
# see also https://stackoverflow.com/questions/14634321/script-to-use-google-image-search-with-local-image-as-input
# https://yandex.com/images/
# https://yandex.com/images/search?source=collections&cbir_id=933558%2FIL8_KPSaP3n5GzB1qtTv6A&rpt=imageview
Add-Type -TypeDefinition @"

using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Web;
namespace MultipartFormData
  {

      public class MultipartFormDataDownloader
      {
        /// <summary>
        /// Creates a multipart/form-data boundary.
        /// </summary>
        /// <returns>
        /// A dynamically generated form boundary for use in posting multipart/form-data requests.
        /// </returns>
        private static string CreateFormDataBoundary()
        {
          return "---------------------------" + DateTime.Now.Ticks.ToString("x");
        }
        public static string ExecutePostRequest(
          Uri url,
          Dictionary<string, string> postData,
          FileInfo fileToUpload,
          string fileMimeType,
          string fileFormKey
        )
        {
          var request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(url.AbsoluteUri);
          request.Method = "POST";
          request.KeepAlive = true;
          string boundary = CreateFormDataBoundary();
          request.ContentType = "multipart/form-data; boundary=" + boundary;
          Stream requestStream = request.GetRequestStream();
          postData.WriteMultipartFormData(requestStream, boundary);
          if (fileToUpload != null) {
            fileToUpload.WriteMultipartFormData(requestStream, boundary, fileMimeType, fileFormKey);
          }
          byte[] endBytes = System.Text.Encoding.UTF8.GetBytes("--" + boundary + "--");
          requestStream.Write(endBytes, 0, endBytes.Length);
          requestStream.Close();
          using (System.Net.WebResponse response = request.GetResponse())
          using (StreamReader reader = new StreamReader(response.GetResponseStream())) {
            return reader.ReadToEnd();
          };
        }
      }
    }

    /// <summary>
    /// Extension methods for generic dictionaries.
    /// </summary>
    public static class DictionaryExtensions
    {
      /// <summary>
      /// Template for a multipart/form-data item.
      /// </summary>
      public const string FormDataTemplate = "--{0}\r\nContent-Disposition: form-data; name=\"{1}\"\r\n\r\n{2}\r\n";

      /// <summary>
      /// Writes a dictionary to a stream as a multipart/form-data set.
      /// </summary>
      /// <param name="dictionary">The dictionary of form values to write to the stream.</param>
      /// <param name="stream">The stream to which the form data should be written.</param>
      /// <param name="mimeBoundary">The MIME multipart form boundary string.</param>
      /// <exception cref="System.ArgumentNullException">
      /// Thrown if <paramref name="stream" /> or <paramref name="mimeBoundary" /> is <see langword="null" />.
      /// </exception>
      /// <exception cref="System.ArgumentException">
      /// Thrown if <paramref name="mimeBoundary" /> is empty.
      /// </exception>
      /// <remarks>
      /// If <paramref name="dictionary" /> is <see langword="null" /> or empty,
      /// nothing wil be written to the stream.
      /// </remarks>
      public static void WriteMultipartFormData(
        this Dictionary<string, string> dictionary,
        Stream stream,
        string mimeBoundary)
      {
        if (dictionary == null || dictionary.Count == 0) {
          return;
        }
        if (stream == null) {
          throw new ArgumentNullException("stream");
        }
        if (mimeBoundary == null) {
          throw new ArgumentNullException("mimeBoundary");
        }
        if (mimeBoundary.Length == 0) {
          throw new ArgumentException("MIME boundary may not be empty.", "mimeBoundary");
        }
        foreach (string key in dictionary.Keys) {
          string item = String.Format(FormDataTemplate, mimeBoundary, key, dictionary[key]);
          byte[] itemBytes = System.Text.Encoding.UTF8.GetBytes(item);
          stream.Write(itemBytes, 0, itemBytes.Length);
        }
      }
    }

    /// <summary>
    /// Extension methods for <see cref="System.IO.FileInfo"/>.
    /// </summary>
    public static class FileInfoExtensions
    {
      /// <summary>
      /// Template for a file item in multipart/form-data format.
      /// </summary>
      public const string HeaderTemplate = "--{0}\r\nContent-Disposition: form-data; name=\"{1}\"; filename=\"{2}\"\r\nContent-Type: {3}\r\n\r\n";

      /// <summary>
      /// Writes a file to a stream in multipart/form-data format.
      /// </summary>
      /// <param name="file">The file that should be written.</param>
      /// <param name="stream">The stream to which the file should be written.</param>
      /// <param name="mimeBoundary">The MIME multipart form boundary string.</param>
      /// <param name="mimeType">The MIME type of the file.</param>
      /// <param name="formKey">The name of the form parameter corresponding to the file upload.</param>
      /// <exception cref="System.ArgumentNullException">
      /// Thrown if any parameter is <see langword="null" />.
      /// </exception>
      /// <exception cref="System.ArgumentException">
      /// Thrown if <paramref name="mimeBoundary" />, <paramref name="mimeType" />,
      /// or <paramref name="formKey" /> is empty.
      /// </exception>
      /// <exception cref="System.IO.FileNotFoundException">
      /// Thrown if <paramref name="file" /> does not exist.
      /// </exception>
      public static void WriteMultipartFormData(
        this FileInfo file,
        Stream stream,
        string mimeBoundary,
        string mimeType,
        string formKey)
      {
        if (file == null) {
          throw new ArgumentNullException("file");
        }
        if (!file.Exists) {
          throw new FileNotFoundException("Unable to find file to write to stream.", file.FullName);
        }
        if (stream == null) {
          throw new ArgumentNullException("stream");
        }
        if (mimeBoundary == null) {
          throw new ArgumentNullException("mimeBoundary");
        }
        if (mimeBoundary.Length == 0) {
          throw new ArgumentException("MIME boundary may not be empty.", "mimeBoundary");
        }
        if (mimeType == null) {
          throw new ArgumentNullException("mimeType");
        }
        if (mimeType.Length == 0) {
          throw new ArgumentException("MIME type may not be empty.", "mimeType");
        }
        if (formKey == null) {
          throw new ArgumentNullException("formKey");
        }
        if (formKey.Length == 0) {
          throw new ArgumentException("Form key may not be empty.", "formKey");
        }
        string header = String.Format(HeaderTemplate, mimeBoundary, formKey, file.Name, mimeType);
        byte[] headerbytes = Encoding.UTF8.GetBytes(header);
        stream.Write(headerbytes, 0, headerbytes.Length);
        using (FileStream fileStream = new FileStream(file.FullName, FileMode.Open, FileAccess.Read)) {
          byte[] buffer = new byte[1024];
          int bytesRead = 0;
          while ((bytesRead = fileStream.Read(buffer, 0, buffer.Length)) != 0) {
            stream.Write(buffer, 0, bytesRead);
          }
          fileStream.Close();
        }
        byte[] newlineBytes = Encoding.UTF8.GetBytes("\r\n");
        stream.Write(newlineBytes, 0, newlineBytes.Length);
      }
  
}

"@ -ReferencedAssemblies 'System.dll','System.Data.dll','System.Web.dll'


$searchUrl = 'http://www.google.com/searchbyimage/upload'
$searchUrl = 'https://yandex.com/images/'
# $imageFilePath = "$($env:USERPROFILE)/Pictures/butterfly-resized.jpg"
$imageFilePath = 'C:\developer\sergueik\powershell_selenium\utils\butterfly-resized.jpg';
[MultipartFormData.MultipartFormDataDownloader]::ExecutePostRequest($searchUrl,@{},$imageFilePath,'image/jpeg','dummy_formkey')
<#
Exception calling "ExecutePostRequest" with "5" argument(s): 
"The process cannot access the file 'C:\Users\Serguei\Pictures\butterfly-resized.jpg' because it is being used by another process."
#>
# c:\Windows\Microsoft.NET\Framework\v2.0.50727\System.dll
# System.Web.dll
<#
#!/usr/bin/env python
import sys
filePath = sys.argv[-1]

import requests

searchUrl = 'http://www.google.com/searchbyimage/upload'
multipart = {'encoded_image': (filePath, open(filePath, 'rb')), 'image_content': ''}
response = requests.post(searchUrl, files=multipart, allow_redirects=False)
fetchUrl = response.headers['Location']
print fetchUrl
import subprocess
subprocess.call([r'/opt/firefox/firefox', fetchUrl])


#>
# https://community.developer.atlassian.com/t/powershell-invoke-restmethod-uploading-new-attachment-to-jira-ticket/6184
# https://stackoverflow.com/questions/22921529/powershell-webrequest-post?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
$response = Invoke-RestMethod -Uri $searchUrl -Method POST -InFile $imageFilePath
# returnt the fullpage

# https://get-powershellblog.blogspot.com/2017/09/multipartform-data-support-for-invoke.html
# Unable to find type [System.Net.Http.MultipartFormDataContent].
# $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$multipartFile = $imageFilePath
$FileStream = [System.IO.FileStream]::new($multipartFile,[System.IO.FileMode]::Open)
# $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$fileHeader.Name = "butterfly-resized"
$fileHeader.FileName = 'butterfly-resized.jpg'
$fileContent = [System.Net.Http.StreamContent]::new($FileStream)
# $fileContent.Headers.ContentDisposition = $fileHeader
# Unable to find type [System.Net.Http.Headers.MediaTypeHeaderValue].
# $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("text/plain")
$multipartContent.Add($fileContent)

$webresponse = Invoke-WebRequest -Uri $searchUrl -Body $multipartContent -Method 'POST'
$webresponse.Headers
# start-process 
# $Body = [byte[]][char[]]'asdf';
# $Request = [System.Net.HttpWebRequest]::CreateHttp($searchUrl);
# $Request.Method = 'POST';
# $Stream = $Request.GetRequestStream();
# $Stream.Write($Body, 0, $Body.Length);
# $Request.GetResponse();

function Get-GoogleImageSearchUrl
{
  param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$ImagePath
  )

  # extract the image file name, without path
  $fileName = Split-Path $imagePath -Leaf

  # the request body has some boilerplate before the raw image bytes (part1) and some after (part2)
  #   note that $filename is included in part1
  $part1 = @"
-----------------------------7dd2db3297c2202
Content-Disposition: form-data; name="encoded_image"; filename="$fileName"
Content-Type: image/jpeg


"@
  $part2 = @"
-----------------------------7dd2db3297c2202
Content-Disposition: form-data; name="image_content"


-----------------------------7dd2db3297c2202--

"@

  # grab the raw bytes composing the image file
  $imageBytes = [Io.File]::ReadAllBytes($imagePath)

  # the request body should sandwich the image bytes between the 2 boilerplate blocks
  $encoding = New-Object Text.ASCIIEncoding
  $data = $encoding.GetBytes($part1) + $imageBytes + $encoding.GetBytes($part2)

  # create the HTTP request, populate headers
  # $request = [Net.HttpWebRequest]([Net.HttpWebRequest]::Create('http://images.google.com/searchbyimage/upload'))
  $request = [Net.HttpWebRequest]([Net.HttpWebRequest]::Create($searchUrl))
  $request.Method = "POST"
  $request.ContentType = 'multipart/form-data; boundary=---------------------------7dd2db3297c2202' # must match the delimiter in the body, above
  $request.ContentLength = $data.Length

  # don't automatically redirect to the results page, just take the response which points to it
  $request.AllowAutoredirect = $false

  # populate the request body
  $stream = $request.GetRequestStream()
  $stream.Write($data,0,$data.Length)
  $stream.Close()

  # get response stream, which should contain a 302 redirect to the results page
  $respStream = $request.GetResponse().GetResponseStream()

  # pluck out the results page link that you would otherwise be redirected to
  (New-Object Io.StreamReader $respStream).ReadToEnd() -match 'HREF\="([^"]+)"' | Out-Null
  $matches[1]
}
# Usage:
# 
$url = Get-GoogleImageSearchUrl $imageFilePath
Start-Process $url

