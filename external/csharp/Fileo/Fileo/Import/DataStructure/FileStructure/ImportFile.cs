using Fileo.Common;
using Fileo.Extensions;
using System;
using System.IO;
using System.Web;

namespace Fileo.Import.DataStructure.FileStructure
{
    internal class ImportFile : IDisposable
    {
        internal Stream FileStream { get; }
        internal FileFormat FileFormat { get; private set; }
        internal string IncorrectFileFormat { get; private set; }

        public ImportFile(HttpPostedFileBase httpPostedFileBase)
        {
            Validate(httpPostedFileBase);

            FileStream = httpPostedFileBase.InputStream;
        }
        
        #region Private methods

        private void Validate(HttpPostedFileBase httpPostedFileBase)
        {
            if (httpPostedFileBase == null)
            {
                throw new ArgumentNullException(nameof(httpPostedFileBase));
            }

            if (httpPostedFileBase.InputStream == Stream.Null)
            {
                throw new ArgumentNullException("httpPostedFileBase.InputStream");
            }

            if (!httpPostedFileBase.FileName.HasValue())
            {
                throw new ArgumentNullException("httpPostedFileBase.FileName");
            }

            ResolveFileFormat(httpPostedFileBase.FileName);
        }
        
        private void ResolveFileFormat(string fileName)
        {
            var fileExtension = Path.GetExtension(fileName) ?? string.Empty;
            
            FileFormat fileFormat;
            if (!Enum.TryParse(fileExtension.Replace(".", ""), true, out fileFormat))
            {
                FileFormat = FileFormat.None;
                IncorrectFileFormat = fileExtension;
            }

            FileFormat = fileFormat;
        }

        public void Dispose()
        {
            this.FileStream.Close();
        }

        #endregion Private methods
    }
}
