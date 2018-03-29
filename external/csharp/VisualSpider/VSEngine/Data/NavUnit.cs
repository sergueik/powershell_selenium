using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace VSEngine.Data
{
    public enum NavType
    {
        URL, Script
    }

    public class NavUnit
    {
        public Guid ID { get; set; }
        public Uri Address { get; set; }
        public string AddressHash { get; set; }
        public DateTime TimeFound { get; set; }
        public NavType Type { get; set; }
        public string ScriptRef { get; set; }

        public NavUnit() { }

        public NavUnit(string url)
        {
            ID = Guid.NewGuid();
            Address = new Uri(url);
            AddressHash = CalculateMD5Hash(url);
            TimeFound = DateTime.Now;
            Type = NavType.URL;
            ScriptRef = string.Empty;
        }

        public static string CalculateMD5Hash(string input)
        {

            // step 1, calculate MD5 hash from input

            MD5 md5 = System.Security.Cryptography.MD5.Create();

            byte[] inputBytes = System.Text.Encoding.ASCII.GetBytes(input);

            byte[] hash = md5.ComputeHash(inputBytes);

            // step 2, convert byte array to hex string

            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < hash.Length; i++)

            {

                sb.Append(hash[i].ToString("X2"));

            }

            return sb.ToString();

        }
    }
}
