param(
  [switch]$hap_docebug
)

$shared_assemblies = @(
  'HtmlAgilityPack.dll',
  'CsQuery.dll', 
  'nunit.framework.dll'
)

$shared_assemblies_path = 'C:\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


$rawdata = @"
  <div class="box-listblogs">
    <div class="box-listblogs-scroll scroll-pane-3">
      <ul id="hof">
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1828215.aspx" title="Lauren! ">Lauren! </a>
            </h3>
            <div class="desc">
              <p>I think you have to create an account to reply to this. If and when you do, please reply.

i miss you. <a href="http://www.carnival.com/Funville/forums/thread/1828215.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Sun, 17 May 2015</span> - <span>Comments (<span/>)</span></p>
             <!-- 
Half way to retirement and I like how things are going!
Now I have to grapple with getting a countdown thingy so I can wallow in my excitement! <a href="http://www.carnival.com/Funville/forums/thread/1828666.aspx">...read more</a></p></div><p class="data"><span class="date">Mon, 18 May 2015</span> - <span>Comments (<span></span>)</span></p></div></li><li><div class="box-listblogs-content"><h3><a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1830802.aspx" title="Grammy Scott">Grammy Scott</a></h3><div class="desc"><p>Test <a href="http://www.carnival.com/Funville/forums/thread/1830802.aspx">...read more</a></p></div><p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span></span>)</span></p></div></li><li><div class="box-listblogs-content"><h3><a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1831112.aspx" title="Entertainment info?">Entertainment info?</a></h3><div class="desc"><p>I have seen people talk about what comedian will be on their cruise and such. I have looked and can't seem to figure out how to find out about any entertainment that will be on my particular cruise. If someone could point me in the right direction... <a href="http://www.carnival.com/Funville/forums/thread/1831112.aspx">...read more</a></p></div><p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span></span>)</span></p></div></li><li><div class="box-listblogs-content"><h3><a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1824843.aspx" title="Cruising on the Glory Jan. 23/16">Cruising on the Glory Jan. 23/16</a></h3><div class="desc"><p>Hello everyone! Be sure if your cruising on the Glory January 23/16' you look for our group.
we are from Regina Saskatchewan. Home of the CFL saskatchewan Rough Riders and proud of them.
There are so far, 11 of us on this cruise and some are crui <a href="http://www.carnival.com/Funville/forums/thread/1824843.aspx">...read more</a></p></div><p class="data"><span class="date">Sun, 10 May 2015</span> - <span>Comments (<span></span>)</span></p></div></li><li><div class="box-listblogs-content"><h3><a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1805458.aspx" title="Who" s="" going="" on="" june="" 2015??'="">Who's going on June 1, 2015??</a></h3><div class="desc"><p>My family is booked on the Triumph leaving from Galveston on June 1. Who else is going? <a href="http://www.carnival.com/Funville/forums/thread/1805458.aspx">...read more</a></p></div><p class="data"><span class="date">Sat, 28 Mar 2015</span> - <span>Comments (<span></span>)</span>
--> 
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1830947.aspx" title="places to secure your belongings on the beach">places to secure your belongings on the beach</a>
            </h3>
            <div class="desc">
              <p>Does anyone know if there are lockers or anywhere to place your belongings when you go on shore to the beach at Grand Turk? <a href="http://www.carnival.com/Funville/forums/thread/1830947.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1831036.aspx" title="&#x201C;Chocolate Delight&#x201D; Question">&#x201C;Chocolate Delight&#x201D; Question</a>
            </h3>
            <div class="desc">
              <p>I was looking at purchasing the&#x201C;Chocolate Delight&#x201D;gift available through the FunShops, but remembered that one of the benefits extended to Platinum members is also listed as a&#x201C;Chocolate Delight&#x201D;.
I haven't cruised on a 5+ day sailing since I was a <a href="http://www.carnival.com/Funville/forums/thread/1831036.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1831003.aspx" title="Boarding Together With a Suite and Interior Rooms">Boarding Together With a Suite and Interior Rooms</a>
            </h3>
            <div class="desc">
              <p>I am cruising on the Vista in July, 2016. 
I have my wife, our kids (2-18 yoa, 7, and 9). I have a suite for the wife and myself, and two interiors right across the hall for the kids.
We get the priority boarding with the suite. Does anyone have any  <a href="http://www.carnival.com/Funville/forums/thread/1831003.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1589557.aspx" title="Funny quotes or pictures...">Funny quotes or pictures...</a>
            </h3>
            <div class="desc">
              <p>Know anyone in your life this can apply to?

 <a href="http://www.carnival.com/Funville/forums/thread/1589557.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Thu, 06 Mar 2014</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1828666.aspx" title="First ever 2nd cruise in a year!!">First ever 2nd cruise in a year!!</a>
            </h3>
            <div class="desc">
              <p>I have now officially booked my first ever 2nd cruise in a year (tee hee)!! 
Half way to retirement and I like how things are going!
Now I have to grapple with getting a countdown thingy so I can wallow in my excitement! <a href="http://www.carnival.com/Funville/forums/thread/1828666.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Mon, 18 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1514429.aspx" title="Let" s="" play="" funville="" word="" association="">Let's Play Funville Word Association</a>
            </h3>
            <div class="desc">
              <p>Sarcasm <a href="http://www.carnival.com/Funville/forums/thread/1514429.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Tue, 05 Nov 2013</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1821227.aspx" title="Late board sun may 3 on breeze?">Late board sun may 3 on breeze?</a>
            </h3>
            <div class="desc">
              <p>I am in a Facebook group and some people have been receiving calls/emails about a late board on sun may 3 on breeze. I am a platinum cruiser and have received no such information. Can you please let me know if we are boarding late. Thanks!
 <a href="http://www.carnival.com/Funville/forums/thread/1821227.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Fri, 01 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1651730.aspx" title="Last letter game">Last letter game</a>
            </h3>
            <div class="desc">
              <p>Wanna try a new game? 
I'll start with a word
Now, you post a cruise-related word that starts with the last letter of my word.
If you get stuck on a letter, you can post a picture related to the last word, and then start over with a new word.

Fir <a href="http://www.carnival.com/Funville/forums/thread/1651730.aspx">...read more</a></p>
            </div>
            <p class="data"><span class="date">Wed, 18 Jun 2014</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
        <li>
          <div class="box-listblogs-content">
            <h3>
              <a class="carnivalLink" href="http://www.carnival.com/Funville/forums/thread/1830842.aspx" title="Were is the fine print?">Were is the fine print?</a>
            </h3>
            <div class="desc">
              <p>I received a offer to cruise at a discounted rate that said offer was good until today the 21st. Well they don't state that was eastern time and since I live in california9THREE HOURS AHEAD), I in good faith went to reserve my cruse and what a surpri <a href="http://www.carnival.com/Funville/forums/thread/1830842.aspx">...read more</a></p>
            </div>
            <p class="data">&nbsp;<span class="date">Fri, 22 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
      </ul>
    </div>
  </div>
  <a class="link-readcarnivalblog" href="/Funville/forums">Go to The Forums</a>

"@
# https://htmlagilitypack.codeplex.com/
# 
[HtmlAgilityPack.HtmlDocument]$hap_doc = New-Object HtmlAgilityPack.HtmlDocument
$hap_doc.LoadHtml($rawdata)

if ($hap_doc.ParseErrors -ne $null -and $hap_doc.ParseErrors.Count -gt 0)
{
  Write-Output 'Handle any parse errors as required'
}

$ns = $hap_doc.DocumentNode.SelectNodes('//a[@class="carnivalLink"]')

$ns | ForEach-Object {


  Write-Output ($_.Attributes["href"].Value)
  Write-Output ($_.InnerText)
}
$cq_doc = new-object CsQuery.CQ($rawdata)

$ns = $cq_doc['a[class="carnivalLink"]']
$ns | ForEach-Object {


  Write-Output ($_.href)
  Write-Output ($_.InnerText.Trim())
}
