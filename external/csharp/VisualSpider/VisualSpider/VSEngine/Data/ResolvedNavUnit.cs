using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace VSEngine.Data
{
    public class ResolvedNavUnit : NavUnit
    {
        public string ContentHash { get; set; }
        public DateTime TimeScrapped { get; set; }
        public Uri ResolvedAddress { get; set; }
        public byte[] Image { get; set; }

        public List<string> URLSFound { get; set; }
        public List<string> ScriptErrors { get; set; }
        public List<string> NavigationErrors { get; set; }

        public List<NavUnit> LinkedURLs { get; set; }

        public ResolvedNavUnit(NavUnit nav, Uri resolved, byte[] image, string contentHash)
        {
            this.Address = nav.Address;
            this.ID = nav.ID;
            this.AddressHash = nav.AddressHash;
            this.TimeFound = nav.TimeFound;
            this.Type = nav.Type;
            this.ScriptRef = nav.ScriptRef;
            ResolvedAddress = resolved;
            Image = image;
            TimeScrapped = DateTime.Now;
            ContentHash = contentHash;

            URLSFound = new List<string>();
            NavigationErrors = new List<string>();
        }
    }
}
