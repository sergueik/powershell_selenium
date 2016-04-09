using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web;
using System.Web.Http;
using System.Web.Http.Cors;
using log4net;

namespace HostMe
{
    public class StaticContentController : ApiController
    {
        private readonly ILog _logger = Logger.GetLogger();
        public static string SiteRootPath { get; set; }

        [EnableCors("*", "*", "*")]
        [Route("{*path}")]
        public HttpResponseMessage GetContent(string path)
        {
            _logger.Info("Got request. path = " + path);

            var absolutePath = GetAbsolutePath(path);

            _logger.Info("Absolute path = " + absolutePath);

            try
            {
                var response = PrepareResponseForPath(absolutePath);

                _logger.InfoFormat("Response for {0} sent!", path);
                return response;
            }
            catch (Exception exception)
            {
                _logger.Warn(absolutePath + " could not be parsed.", exception);
                _logger.Warn("Responding with Bad Request!");
                throw new HttpResponseException(HttpStatusCode.BadRequest);
            }
        }

        private HttpResponseMessage PrepareResponseForPath(string path)
        {
            var content = File.ReadAllBytes(path);
            _logger.Info("Content read from: " + path);

            var mediaType = MimeMapping.GetMimeMapping(Path.GetFileName(path));
            _logger.Info("Media Type found = " + mediaType);

            var response = new HttpResponseMessage
            {
                Content = new ByteArrayContent(content)
            };

            response.Content.Headers.ContentType = new MediaTypeHeaderValue(mediaType);

            return response;
        }

        private static string GetAbsolutePath(string path)
        {
            if (path == null)
                path = "index.html";

            return Path.Combine(SiteRootPath, path);
        }
    }
}
