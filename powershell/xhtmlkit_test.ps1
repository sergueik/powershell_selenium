# origin https://www.codeproject.com/Articles/1231184/Scraping-Web-Pages-with-XHtmlKit
# using XHtmlKit
# https://github.com/jrsell/XHtmlKit
# download XHtmlKit.1.0.4.nupkg from
# https://www.nuget.org/api/v2/package/XHtmlKit/1.0.4
# and place `XHtmlKit.dll` from net20 or net45 example local folder
# both .net 2.0 and .net 4.5 are available
# the below works with .net4.5 version

$shared_assemblies = @(
  'XHtmlKit.dll',
  # 'nunit.core.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = "${env:USERPROFILE}\Downloads"

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  write-output $_
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd

Add-Type -TypeDefinition @"

// "
using System.Collections.Generic;
using System.Xml;
using XHtmlKit;
using System.Text;
using System.Threading.Tasks;
using System;
using System.Collections;
using NUnit.Framework;

namespace SampleScraper
{
	public class Program
	{
		public static void Run(string[] args)
		{
			// Get data
			MyScraper scraper = new MyScraper();
			int pageNum = 1;
			String url = "https://www.codeproject.com/script/Articles/Latest.aspx?pgnum=" + pageNum;
			String nodeSelector = "//table[contains(@class,'article-list')]/tr[@valign]"; 
			scraper.Url = url;
			scraper.NodeSelector = nodeSelector;
			Hashtable selectors = new Hashtable();
			selectors.Add("category", "./td[1]//a/text()"); 
			selectors.Add("title", ".//div[@class='title']/a/text()"); 
			selectors.Add("date", ".//div[contains(@class,'modified')]/text()"); 
			selectors.Add("rating", ".//div[contains(@class,'rating-stars')]/@title"); 
			selectors.Add("desc", ".//div[@class='description']/text()"); 
			selectors.Add("author", ".//div[contains(@class,'author')]/text()"); 
			selectors.Add("tag", ".//div[@class='t']/a/text()"); 
      
			scraper.Selectors = selectors;
			Hashtable[] articles = scraper.GetCodeProjectArticlesAsync().Result;

			// Do something with data
			foreach (Hashtable a in articles) {
				Console.WriteLine(a["date"] + ", " + a["title"] + ", " + a["rating"] + ", " + a["tag"]);
			}
			// TODO
		}
	}
	public  class MyScraper
	{
		private Hashtable elements = new Hashtable();
		private Hashtable selectors = new Hashtable();
		public Hashtable Selectors {
			set {
				this.selectors = value;
			}
		}
		/*
		public Hashtable Elements {
			get {
				return this.elements;
			}
		}
    */
		private String nodeSelector;
		private String url;
		public String NodeSelector {
			set {
				this.nodeSelector = value;
			}
		}
		public String Url {
			set {
				this.url = value;
			}
		}
		private XmlDocument page;
		public MyScraper()
		{
			
		}
		
		public async Task<Hashtable[]> GetCodeProjectArticlesAsync(int pageNum = 1)
		{
			List<Hashtable> results = new List<Hashtable>();
			Assert.IsNotNull(url);
			Assert.IsNotNull(nodeSelector);
			Assert.IsNotEmpty(selectors.Keys);

			// Get web page as an XHtml document using XHtmlKit
			page = await XHtmlLoader.LoadWebPageAsync(url);

			// Select all articles using an anchor node containing a robust @class attribute
			var nodes = page.SelectNodes(nodeSelector);

			// Get each article
			foreach (XmlNode node in nodes) {
				// Extract data
           
				elements = new Hashtable();
				foreach (String field in selectors.Keys) {
					String selector = (String)selectors[field];
					var data = node.SelectSingleNode(selector);
					elements.Add(field, data != null ? data.Value : string.Empty);
          try {
					  Console.Error.WriteLine(field + " " + selector + ": " + data.Value); 
          } catch (Exception ) {}
					// experimental
          
					XmlNodeList dataNodes = node.SelectNodes(selector);
					if (dataNodes.Count == 0) {
						elements[field] = string.Empty;
					} else if (dataNodes.Count == 1) {
						elements[field] = dataNodes[0].Value;
					} else { 
						StringBuilder dataCollector = new StringBuilder();
						foreach (XmlNode dataNode in dataNodes)
							dataCollector.Append((dataCollector.Length > 0 ? "," : "") + dataNode.Value);
						elements[field] = dataCollector.ToString();
					}
          

				} 
				// Add to results
				results.Add(elements);  
				// TODO:
				/*
				XmlNodeList tagNodes = a.SelectNodes(".//div[@class='t']/a/text()");
				StringBuilder tags = new StringBuilder();
				foreach (XmlNode tagNode in tagNodes)
					tags.Append((tags.Length > 0 ? "," : "") + tagNode.Value);
				*/
			}
			return results.ToArray();
		}
	}
}

"@ -ReferencedAssemblies "${shared_assemblies_path}\XHtmlKit.dll","${shared_assemblies_path}\nunit.framework.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'


[SampleScraper.Program]::Run(@());