#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
param(
  # in the current environment phantomejs is not installed 
  [string]$browser = 'chrome',
  [string]$dest = 'Europe',
  [string]$port = 'Trieste',
  [switch]$pause

)

$verificationErrors = New-Object System.Text.StringBuilder

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid

} else {
  $selenium = launch_selenium -browser $browser

}

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
$base_url = 'http://www.carnival.com/Funville/'
# 
# html.js.borderradius.boxshadow.textshadow.csstransitions.js.no-touch.boxshadow.cssanimations.csstransitions

$selenium.Navigate().GoToUrl($base_url + '/')
Write-Debug ('Started with {0}' -f $selenium.Title)
[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))

$logo_css_selector = 'a[href="/Funville"]'
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($logo_css_selector)))



$selenium.Manage().Window.Maximize()
$forum_search_css_selector = 'ul.ui-tabs-nav'
$value_element1 = find_element_new -css $forum_search_css_selector
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$value_element1).Build().Perform()
$actions = $null
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$value_element1)

$forum_tab_css_selector = 'a[href="#tab-hof"]'
$value_element2 = find_element_new -css $forum_tab_css_selector
# -container_element_ref ([ref]$value_element1) is unused 
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$value_element2).Click().Build().Perform()
$actions = $null
highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$value_element2)

$forums = @"

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
            <p class="data"><span class="date">Fri, 22 May 2015</span> - <span>Comments (<span/>)</span></p>
          </div>
        </li>
      </ul>
    </div>
  </div>
  <a class="link-readcarnivalblog" href="/Funville/forums">Go to The Forums</a>

"@
#  NOTE: The actual forums is not well-formed.
# 
$forum_css_selector = 'div#tab-hof'
$value_element3 =  find_element_new -css $forum_css_selector

$raw_data = '<rawdata>{0}</rawdata>' -f ($value_element3.GetAttribute('innerHTML') -join '')
# Pruning the known bad syntax elements:
# Error: "Reference to undeclared entity 'nbsp'."
$raw_data = $raw_data -replace '&nbsp;',''
# Error: "??"
$raw_data = $raw_data -replace " \d+,?\?*\'*=\`"\`"",''
# NOTE: alternative is to use
# 'HtmlAgilityPack.dll',
# 'CsQuery.dll'
$s1 = [xml]$raw_data
$s1.'rawdata'.'div'.'div'.'ul'.'li'.'div'.'h3'.'a' | ForEach-Object {
  Write-Output ($_.GetAttribute('title'))
  Write-Output ($_.GetAttribute('href'))
  $_ | Get-Member | Out-Null
}

$forum_title_css_locator = 'div.box-listblogs-content a.carnivalLink'
$forums = $value_element3.FindElements([OpenQA.Selenium.By]::CssSelector($forum_title_css_locator))

if ($forums.Count -gt 1) {
  0..($forums.Count - 1) | ForEach-Object {
    Write-Output $forums[$_].Text
    Write-Output $forums[$_].GetAttribute('href')
  }

}


<#
$link_forums_xpath = '//a[@class="link-readcarnivalblog"]'
$value_element3 = find_element_new -xpath $link_forums_xpath
#>
<#
$link_forums_css_selector = 'div[class="box-listblogs"] a[class="link-readcarnivalblog"]'
$value_element3 = find_element_new -css $link_forums_css_selector
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$value_element3).Build().Perform()
$actions = $null

highlight -selenium_ref ([ref]$selenium) -element_ref ([ref]$value_element3)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$value_element3).Click().Build().Perform()
$actions = $null

#>

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

# At the end of the run - do not close Browser / Selenium when executing from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
