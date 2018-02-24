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
using SampleScraper;

namespace SampleScraper {
	public class Program {
		public static void Run(string[] args) {
			// Get data
			MyScraper scraper = new MyScraper();
			int pageNum = 1;
			string url = "https://www.codeproject.com/script/Articles/Latest.aspx?pgnum=" + pageNum;
			scraper.Url = url;
			SampleScraper.ArticleDTO[] articles = scraper.GetCodeProjectArticlesAsync().Result;

			// Do something with data
			foreach (SampleScraper.ArticleDTO a in articles) {
				Console.WriteLine(a.Date + ", " + a.Title + ", " + a.Rating);
			}
      // TODO
		}
	}
	public  class MyScraper {
		private String url;
		public String Url {
			get {
				return this.url;
			}
			set {
				this.url = value;
			}
		}
		public XmlDocument Page {
			get {
				return this.page;
			}
			set {
			}
		}
    private XmlDocument page;
		public MyScraper() {
			
		}
		
		public async Task<SampleScraper.ArticleDTO[]> GetCodeProjectArticlesAsync(int pageNum = 1)
		{
			List<SampleScraper.ArticleDTO> results = new List<SampleScraper.ArticleDTO>();

			// Get web page as an XHtml document using XHtmlKit
			page = await XHtmlLoader.LoadWebPageAsync(url);

			// Select all articles using an anchor node containing a robust @class attribute
			var articles = page.SelectNodes("//table[contains(@class,'article-list')]/tr[@valign]");

			// Get each article
			foreach (XmlNode a in articles) {
				// Extract article data - we need to be aware that sometimes there are no results
				// for certain fields
				var category = a.SelectSingleNode("./td[1]//a/text()");
				var title = a.SelectSingleNode(".//div[@class='title']/a/text()");
				var date = a.SelectSingleNode(".//div[contains(@class,'modified')]/text()");
				var rating = a.SelectSingleNode(".//div[contains(@class,'rating-stars')]/@title");
				var desc = a.SelectSingleNode(".//div[@class='description']/text()");
				var author = a.SelectSingleNode(".//div[contains(@class,'author')]/text()");
				XmlNodeList tagNodes = a.SelectNodes(".//div[@class='t']/a/text()");
				StringBuilder tags = new StringBuilder();
				foreach (XmlNode tagNode in tagNodes)
					tags.Append((tags.Length > 0 ? "," : "") + tagNode.Value);

				// Create the data structure we want
				ArticleDTO article = new ArticleDTO {
					Category = category != null ? category.Value : string.Empty,
					Title = title != null ? title.Value : string.Empty,
					Author = author != null ? author.Value : string.Empty,
					Description = desc != null ? desc.Value : string.Empty,
					Rating = rating != null ? rating.Value : string.Empty,
					Date = date != null ? date.Value : string.Empty,
					Tags = tags.ToString()
				};

				// Add to results
				results.Add(article);
			}
			return results.ToArray();
		}
	}

	public class ArticleDTO
	{
		public string Category;
		public string Title;
		public string Rating;
		public string Date;
		public string Author;
		public string Description;
		public string Tags;
	}
}

"@ -ReferencedAssemblies "${shared_assemblies_path}\XHtmlKit.dll",'System.dll','System.Data.dll','Microsoft.CSharp.dll','System.Xml.Linq.dll','System.Xml.dll'


[SampleScraper.Program]::Run(@());