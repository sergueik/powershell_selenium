using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VSEngine.Data
{
    public class Config
    {
        public string StartURL { get; set; }
        public int MaxThreads { get; set; }

        public void GenerateConfig ()
        {
            StartURL = "http://www.google.com";
            MaxThreads = 4;
        }
    }
}
