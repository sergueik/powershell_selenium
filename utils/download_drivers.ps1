#Copyright (c) 2018 Serguei Kouzmine
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

# This script extracts download link for latest version of Seleium driver from release page XML, JSON or HTML as applicable

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-6

# chrome:
$available_plaforms = @(
  'mac32',
  'win32',
  # NOTE: no 'win64'
  'linux32',
  'linux64'
)
$plaform = 'win32'

$release_url = 'https://chromedriver.storage.googleapis.com/'
$latest_release_url = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE'
$latest_version = (invoke-webrequest -uri $latest_release_url).Content
$base_url = $release_url

$download_url = ('{0}{1}/chromedriver_{2}.zip' -f $base_url, $latest_version, $plaform)

write-output ('Latest version: {0}' -f $latest_version)
write-output ('Download url: {0}' -f $download_url)
<#
e.g.
  Latest version: 2.41
  Download url: https://chromedriver.storage.googleapis.com/2.41/chromedriver_win32.zip
#>
# Alternative chrome

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $release_url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}
$o = [xml]$content

# TODO: filtering by platform and CPU architecture
$contents = $o.'ListBucketResult'.'Contents'
$releases = @{}
$contents |
foreach-object {
$contents_element = $_
  if ($debugPReference -eq 'continue'){
    $contents_element | select-object -property *
  }
  $key = $contents_element.Key
  if ($key -match 'debug' ) {
    return
  }
  if ($key -match $plaform ) {
    $download_url = ('{0}{1}'-f $base_url, $key )
    if ($key -match '\b(?<version>[0-9]+\.[0-9]+)\b' ){
      $version = $matches['version']
      $version_key = 0 + ($version -replace '.(\d)', '000$1')
      # write-output $version
      # write-output $download_url
      $release_info = @{}
      $release_info['version'] = $version
      $release_info['download_url'] = $download_url
      $releases[$version_key] = $release_info
    }
  }
}
$latest_release = $releases.GetEnumerator() | sort -Property name -descending | select-object -first 1
$latest_release.Value | format-list

# firefox:
$available_plaforms = @(
  'arm7hf',
  'linux32',
  'linux64',
  'macos',
  'win32',
  'win64',
  'osx'
)

$platform = 'win32'

$release_url = 'https://github.com/mozilla/geckodriver/releases'
# origin: https://github.com/lukesampson/scoop/issues/2063
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 'ParsedHtml' is too slow. appears to be hanging
# (invoke-webrequest -uri $url).$o.ParsedHtml

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $release_url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getelementsByClassName('release-title')

$html2   = New-Object -ComObject 'HTMLFile'

$html2.IHTMLDocument2_write($nodes[0].innerhtml )
$html2.getElementsByTagName('A')[0].innerText
# e.g. v0.21.0
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
remove-variable html2


# TODO: filtering
0..($nodes.length) |
foreach-object {
$cnt = $_
$node = $nodes.item($cnt)
$html2   = New-Object -ComObject 'HTMLFile'
$html2.IHTMLDocument2_write($node.innerhtml )
$element =  $html2.getElementsByTagName('A')[0]
# $element | get-member
<#
addBehavior                  Method     int addBehavior (string, Variant)
addFilter                    Method     void addFilter (IUnknown)
appendChild                  Method     IHTMLDOMNode appendChild (IHTMLDOMNode)
applyElement                 Method     IHTMLElement applyElement (IHTMLElem...
attachEvent                  Method     bool attachEvent (string, IDispatch)
blur                         Method     void blur ()
clearAttributes              Method     void clearAttributes ()
click                        Method     void click ()
cloneNode                    Method     IHTMLDOMNode cloneNode (bool)
compareDocumentPosition      Method     ushort compareDocumentPosition (IHTM...
componentFromPoint           Method     string componentFromPoint (int, int)
contains                     Method     bool contains (IHTMLElement)
createControlRange           Method     IDispatch createControlRange ()
detachEvent                  Method     void detachEvent (string, IDispatch)
doScroll                     Method     void doScroll (Variant)
dragDrop                     Method     bool dragDrop ()
FireEvent                    Method     bool FireEvent (string, Variant)
focus                        Method     void focus ()
getAdjacentText              Method     string getAdjacentText (string)
getAttribute                 Method     Variant getAttribute (string, int)
getAttributeNode             Method     IHTMLDOMAttribute getAttributeNode (...
getAttributeNodeNS           Method     IHTMLDOMAttribute2 getAttributeNodeN...
getAttributeNS               Method     Variant getAttributeNS (Variant, str...
getBoundingClientRect        Method     IHTMLRect getBoundingClientRect ()
getClientRects               Method     IHTMLRectCollection getClientRects ()
getElementsByClassName       Method     IHTMLElementCollection getElementsBy...
getElementsByTagName         Method     IHTMLElementCollection getElementsBy...
getElementsByTagNameNS       Method     IHTMLElementCollection getElementsBy...
getExpression                Method     Variant getExpression (string)
hasAttribute                 Method     bool hasAttribute (string)
hasAttributeNS               Method     bool hasAttributeNS (Variant, string)
hasAttributes                Method     bool hasAttributes ()
hasChildNodes                Method     bool hasChildNodes ()
ie8_getAttribute             Method     Variant ie8_getAttribute (string)
ie8_getAttributeNode         Method     IHTMLDOMAttribute2 ie8_getAttributeN...
ie8_removeAttribute          Method     bool ie8_removeAttribute (string)
ie8_removeAttributeNode      Method     IHTMLDOMAttribute2 ie8_removeAttribu...
ie8_setAttribute             Method     void ie8_setAttribute (string, Variant)
ie8_setAttributeNode         Method     IHTMLDOMAttribute2 ie8_setAttributeN...
ie9_appendChild              Method     IHTMLDOMNode ie9_appendChild (IHTMLD...
ie9_getAttribute             Method     Variant ie9_getAttribute (string)
ie9_getAttributeNode         Method     IHTMLDOMAttribute2 ie9_getAttributeN...
ie9_hasAttribute             Method     bool ie9_hasAttribute (string)
ie9_hasAttributes            Method     bool ie9_hasAttributes ()
ie9_insertBefore             Method     IHTMLDOMNode ie9_insertBefore (IHTML...
ie9_removeAttribute          Method     void ie9_removeAttribute (string)
ie9_removeAttributeNode      Method     IHTMLDOMAttribute2 ie9_removeAttribu...
ie9_removeChild              Method     IHTMLDOMNode ie9_removeChild (IHTMLD...
ie9_replaceChild             Method     IHTMLDOMNode ie9_replaceChild (IHTML...
ie9_setAttribute             Method     void ie9_setAttribute (string, Variant)
ie9_setAttributeNode         Method     IHTMLDOMAttribute2 ie9_setAttributeN...
insertAdjacentElement        Method     IHTMLElement insertAdjacentElement (...
insertAdjacentHTML           Method     void insertAdjacentHTML (string, str...
insertAdjacentText           Method     void insertAdjacentText (string, str...
insertBefore                 Method     IHTMLDOMNode insertBefore (IHTMLDOMN...
isDefaultNamespace           Method     bool isDefaultNamespace (Variant)
isEqualNode                  Method     bool isEqualNode (IHTMLDOMNode3)
isSameNode                   Method     bool isSameNode (IHTMLDOMNode3)
isSupported                  Method     bool isSupported (string, Variant)
lookupNamespaceURI           Method     Variant lookupNamespaceURI (Variant)
lookupPrefix                 Method     Variant lookupPrefix (Variant)
mergeAttributes              Method     void mergeAttributes (IHTMLElement, ...
msMatchesSelector            Method     bool msMatchesSelector (string)
msReleasePointerCapture      Method     void msReleasePointerCapture (int)
msSetPointerCapture          Method     void msSetPointerCapture (int)
normalize                    Method     void normalize ()
querySelector                Method     IHTMLElement querySelector (string)
querySelectorAll             Method     IHTMLDOMChildrenCollection querySele...
releaseCapture               Method     void releaseCapture ()
removeAttribute              Method     bool removeAttribute (string, int)
removeAttributeNode          Method     IHTMLDOMAttribute removeAttributeNod...
removeAttributeNS            Method     void removeAttributeNS (Variant, str...
removeBehavior               Method     bool removeBehavior (int)
removeChild                  Method     IHTMLDOMNode removeChild (IHTMLDOMNode)
removeExpression             Method     bool removeExpression (string)
removeFilter                 Method     void removeFilter (IUnknown)
removeNode                   Method     IHTMLDOMNode removeNode (bool)
replaceAdjacentText          Method     string replaceAdjacentText (string, ...
replaceChild                 Method     IHTMLDOMNode replaceChild (IHTMLDOMN...
replaceNode                  Method     IHTMLDOMNode replaceNode (IHTMLDOMNode)
scrollIntoView               Method     void scrollIntoView (Variant)
setActive                    Method     void setActive ()
setAttribute                 Method     void setAttribute (string, Variant, ...
setAttributeNode             Method     IHTMLDOMAttribute setAttributeNode (...
setAttributeNodeNS           Method     IHTMLDOMAttribute2 setAttributeNodeN...
setAttributeNS               Method     void setAttributeNS (Variant, string...
setCapture                   Method     void setCapture (bool)
setExpression                Method     void setExpression (string, string, ...
swapNode                     Method     IHTMLDOMNode swapNode (IHTMLDOMNode)
toString                     Method     string toString ()
accessKey                    Property   string accessKey () {get} {set}
all                          Property   IDispatch all () {get}
ariaActivedescendant         Property   string ariaActivedescendant () {get}...
ariaBusy                     Property   string ariaBusy () {get} {set}
ariaChecked                  Property   string ariaChecked () {get} {set}
ariaControls                 Property   string ariaControls () {get} {set}
ariaDescribedby              Property   string ariaDescribedby () {get} {set}
ariaDisabled                 Property   string ariaDisabled () {get} {set}
ariaExpanded                 Property   string ariaExpanded () {get} {set}
ariaFlowto                   Property   string ariaFlowto () {get} {set}
ariaHaspopup                 Property   string ariaHaspopup () {get} {set}
ariaHidden                   Property   string ariaHidden () {get} {set}
ariaInvalid                  Property   string ariaInvalid () {get} {set}
ariaLabelledby               Property   string ariaLabelledby () {get} {set}
ariaLevel                    Property   short ariaLevel () {get} {set}
ariaLive                     Property   string ariaLive () {get} {set}
ariaMultiselectable          Property   string ariaMultiselectable () {get} ...
ariaOwns                     Property   string ariaOwns () {get} {set}
ariaPosinset                 Property   short ariaPosinset () {get} {set}
ariaPressed                  Property   string ariaPressed () {get} {set}
ariaReadonly                 Property   string ariaReadonly () {get} {set}
ariaRelevant                 Property   string ariaRelevant () {get} {set}
ariaRequired                 Property   string ariaRequired () {get} {set}
ariaSecret                   Property   string ariaSecret () {get} {set}
ariaSelected                 Property   string ariaSelected () {get} {set}
ariaSetsize                  Property   short ariaSetsize () {get} {set}
ariaValuemax                 Property   string ariaValuemax () {get} {set}
ariaValuemin                 Property   string ariaValuemin () {get} {set}
ariaValuenow                 Property   string ariaValuenow () {get} {set}
attributes                   Property   IDispatch attributes () {get}
behaviorUrns                 Property   IDispatch behaviorUrns () {get}
canHaveChildren              Property   bool canHaveChildren () {get}
canHaveHTML                  Property   bool canHaveHTML () {get}
charset                      Property   string charset () {get} {set}
childNodes                   Property   IDispatch childNodes () {get}
children                     Property   IDispatch children () {get}
className                    Property   string className () {get} {set}
clientHeight                 Property   int clientHeight () {get}
clientLeft                   Property   int clientLeft () {get}
clientTop                    Property   int clientTop () {get}
clientWidth                  Property   int clientWidth () {get}
constructor                  Property   IDispatch constructor () {get}
contentEditable              Property   string contentEditable () {get} {set}
coords                       Property   string coords () {get} {set}
currentStyle                 Property   IHTMLCurrentStyle currentStyle () {g...
dataFld                      Property   string dataFld () {get} {set}
dataFormatAs                 Property   string dataFormatAs () {get} {set}
dataSrc                      Property   string dataSrc () {get} {set}
dir                          Property   string dir () {get} {set}
disabled                     Property   bool disabled () {get} {set}
document                     Property   IDispatch document () {get}
filters                      Property   IHTMLFiltersCollection filters () {g...
firstChild                   Property   IHTMLDOMNode firstChild () {get}
hash                         Property   string hash () {get} {set}
hideFocus                    Property   bool hideFocus () {get} {set}
host                         Property   string host () {get} {set}
hostname                     Property   string hostname () {get} {set}
href                         Property   string href () {get} {set}
hreflang                     Property   string hreflang () {get} {set}
id                           Property   string id () {get} {set}
ie8_attributes               Property   IHTMLAttributeCollection3 ie8_attrib...
ie8_coords                   Property   string ie8_coords () {get} {set}
ie8_href                     Property   string ie8_href () {get} {set}
ie8_shape                    Property   string ie8_shape () {get} {set}
ie9_nodeName                 Property   string ie9_nodeName () {get}
ie9_tagName                  Property   string ie9_tagName () {get}
innerHTML                    Property   string innerHTML () {get} {set}
innerText                    Property   string innerText () {get} {set}
isContentEditable            Property   bool isContentEditable () {get}
isDisabled                   Property   bool isDisabled () {get}
isMultiLine                  Property   bool isMultiLine () {get}
isTextEdit                   Property   bool isTextEdit () {get}
lang                         Property   string lang () {get} {set}
language                     Property   string language () {get} {set}
lastChild                    Property   IHTMLDOMNode lastChild () {get}
localName                    Property   Variant localName () {get}
Methods                      Property   string Methods () {get} {set}
mimeType                     Property   string mimeType () {get}
name                         Property   string name () {get} {set}
nameProp                     Property   string nameProp () {get}
namespaceURI                 Property   Variant namespaceURI () {get}
nextSibling                  Property   IHTMLDOMNode nextSibling () {get}
nodeName                     Property   string nodeName () {get}
nodeType                     Property   int nodeType () {get}
nodeValue                    Property   Variant nodeValue () {get} {set}
offsetHeight                 Property   int offsetHeight () {get}
offsetLeft                   Property   int offsetLeft () {get}
offsetParent                 Property   IHTMLElement offsetParent () {get}
offsetTop                    Property   int offsetTop () {get}
offsetWidth                  Property   int offsetWidth () {get}
onabort                      Property   Variant onabort () {get} {set}
onactivate                   Property   Variant onactivate () {get} {set}
onafterupdate                Property   Variant onafterupdate () {get} {set}
onbeforeactivate             Property   Variant onbeforeactivate () {get} {s...
onbeforecopy                 Property   Variant onbeforecopy () {get} {set}
onbeforecut                  Property   Variant onbeforecut () {get} {set}
onbeforedeactivate           Property   Variant onbeforedeactivate () {get} ...
onbeforeeditfocus            Property   Variant onbeforeeditfocus () {get} {...
onbeforepaste                Property   Variant onbeforepaste () {get} {set}
onbeforeupdate               Property   Variant onbeforeupdate () {get} {set}
onblur                       Property   Variant onblur () {get} {set}
oncanplay                    Property   Variant oncanplay () {get} {set}
oncanplaythrough             Property   Variant oncanplaythrough () {get} {s...
oncellchange                 Property   Variant oncellchange () {get} {set}
onchange                     Property   Variant onchange () {get} {set}
onclick                      Property   Variant onclick () {get} {set}
oncontextmenu                Property   Variant oncontextmenu () {get} {set}
oncontrolselect              Property   Variant oncontrolselect () {get} {set}
oncopy                       Property   Variant oncopy () {get} {set}
oncuechange                  Property   Variant oncuechange () {get} {set}
oncut                        Property   Variant oncut () {get} {set}
ondataavailable              Property   Variant ondataavailable () {get} {set}
ondatasetchanged             Property   Variant ondatasetchanged () {get} {s...
ondatasetcomplete            Property   Variant ondatasetcomplete () {get} {...
ondblclick                   Property   Variant ondblclick () {get} {set}
ondeactivate                 Property   Variant ondeactivate () {get} {set}
ondrag                       Property   Variant ondrag () {get} {set}
ondragend                    Property   Variant ondragend () {get} {set}
ondragenter                  Property   Variant ondragenter () {get} {set}
ondragleave                  Property   Variant ondragleave () {get} {set}
ondragover                   Property   Variant ondragover () {get} {set}
ondragstart                  Property   Variant ondragstart () {get} {set}
ondrop                       Property   Variant ondrop () {get} {set}
ondurationchange             Property   Variant ondurationchange () {get} {s...
onemptied                    Property   Variant onemptied () {get} {set}
onended                      Property   Variant onended () {get} {set}
onerror                      Property   Variant onerror () {get} {set}
onerrorupdate                Property   Variant onerrorupdate () {get} {set}
onfilterchange               Property   Variant onfilterchange () {get} {set}
onfocus                      Property   Variant onfocus () {get} {set}
onfocusin                    Property   Variant onfocusin () {get} {set}
onfocusout                   Property   Variant onfocusout () {get} {set}
onhelp                       Property   Variant onhelp () {get} {set}
oninput                      Property   Variant oninput () {get} {set}
oninvalid                    Property   Variant oninvalid () {get} {set}
onkeydown                    Property   Variant onkeydown () {get} {set}
onkeypress                   Property   Variant onkeypress () {get} {set}
onkeyup                      Property   Variant onkeyup () {get} {set}
onlayoutcomplete             Property   Variant onlayoutcomplete () {get} {s...
onload                       Property   Variant onload () {get} {set}
onloadeddata                 Property   Variant onloadeddata () {get} {set}
onloadedmetadata             Property   Variant onloadedmetadata () {get} {s...
onloadstart                  Property   Variant onloadstart () {get} {set}
onlosecapture                Property   Variant onlosecapture () {get} {set}
onmousedown                  Property   Variant onmousedown () {get} {set}
onmouseenter                 Property   Variant onmouseenter () {get} {set}
onmouseleave                 Property   Variant onmouseleave () {get} {set}
onmousemove                  Property   Variant onmousemove () {get} {set}
onmouseout                   Property   Variant onmouseout () {get} {set}
onmouseover                  Property   Variant onmouseover () {get} {set}
onmouseup                    Property   Variant onmouseup () {get} {set}
onmousewheel                 Property   Variant onmousewheel () {get} {set}
onmove                       Property   Variant onmove () {get} {set}
onmoveend                    Property   Variant onmoveend () {get} {set}
onmovestart                  Property   Variant onmovestart () {get} {set}
onmsanimationend             Property   Variant onmsanimationend () {get} {s...
onmsanimationiteration       Property   Variant onmsanimationiteration () {g...
onmsanimationstart           Property   Variant onmsanimationstart () {get} ...
onmsgesturechange            Property   Variant onmsgesturechange () {get} {...
onmsgesturedoubletap         Property   Variant onmsgesturedoubletap () {get...
onmsgestureend               Property   Variant onmsgestureend () {get} {set}
onmsgesturehold              Property   Variant onmsgesturehold () {get} {set}
onmsgesturestart             Property   Variant onmsgesturestart () {get} {s...
onmsgesturetap               Property   Variant onmsgesturetap () {get} {set}
onmsgotpointercapture        Property   Variant onmsgotpointercapture () {ge...
onmsinertiastart             Property   Variant onmsinertiastart () {get} {s...
onmslostpointercapture       Property   Variant onmslostpointercapture () {g...
onmsmanipulationstatechanged Property   Variant onmsmanipulationstatechanged...
onmspointercancel            Property   Variant onmspointercancel () {get} {...
onmspointerdown              Property   Variant onmspointerdown () {get} {set}
onmspointerhover             Property   Variant onmspointerhover () {get} {s...
onmspointermove              Property   Variant onmspointermove () {get} {set}
onmspointerout               Property   Variant onmspointerout () {get} {set}
onmspointerover              Property   Variant onmspointerover () {get} {set}
onmspointerup                Property   Variant onmspointerup () {get} {set}
onmstransitionend            Property   Variant onmstransitionend () {get} {...
onmstransitionstart          Property   Variant onmstransitionstart () {get}...
onpage                       Property   Variant onpage () {get} {set}
onpaste                      Property   Variant onpaste () {get} {set}
onpause                      Property   Variant onpause () {get} {set}
onplay                       Property   Variant onplay () {get} {set}
onplaying                    Property   Variant onplaying () {get} {set}
onprogress                   Property   Variant onprogress () {get} {set}
onpropertychange             Property   Variant onpropertychange () {get} {s...
onratechange                 Property   Variant onratechange () {get} {set}
onreadystatechange           Property   Variant onreadystatechange () {get} ...
onreset                      Property   Variant onreset () {get} {set}
onresize                     Property   Variant onresize () {get} {set}
onresizeend                  Property   Variant onresizeend () {get} {set}
onresizestart                Property   Variant onresizestart () {get} {set}
onrowenter                   Property   Variant onrowenter () {get} {set}
onrowexit                    Property   Variant onrowexit () {get} {set}
onrowsdelete                 Property   Variant onrowsdelete () {get} {set}
onrowsinserted               Property   Variant onrowsinserted () {get} {set}
onscroll                     Property   Variant onscroll () {get} {set}
onseeked                     Property   Variant onseeked () {get} {set}
onseeking                    Property   Variant onseeking () {get} {set}
onselect                     Property   Variant onselect () {get} {set}
onselectstart                Property   Variant onselectstart () {get} {set}
onstalled                    Property   Variant onstalled () {get} {set}
onsubmit                     Property   Variant onsubmit () {get} {set}
onsuspend                    Property   Variant onsuspend () {get} {set}
ontimeupdate                 Property   Variant ontimeupdate () {get} {set}
onvolumechange               Property   Variant onvolumechange () {get} {set}
onwaiting                    Property   Variant onwaiting () {get} {set}
outerHTML                    Property   string outerHTML () {get} {set}
outerText                    Property   string outerText () {get} {set}
ownerDocument                Property   IDispatch ownerDocument () {get}
parentElement                Property   IHTMLElement parentElement () {get}
parentNode                   Property   IHTMLDOMNode parentNode () {get}
parentTextEdit               Property   IHTMLElement parentTextEdit () {get}
pathname                     Property   string pathname () {get} {set}
port                         Property   string port () {get} {set}
prefix                       Property   Variant prefix () {get} {set}
previousSibling              Property   IHTMLDOMNode previousSibling () {get}
protocol                     Property   string protocol () {get} {set}
protocolLong                 Property   string protocolLong () {get}
readyState                   Property   Variant readyState () {get}
recordNumber                 Property   Variant recordNumber () {get}
rel                          Property   string rel () {get} {set}
rev                          Property   string rev () {get} {set}
role                         Property   string role () {get} {set}
runtimeStyle                 Property   IHTMLStyle runtimeStyle () {get}
scopeName                    Property   string scopeName () {get}
scrollHeight                 Property   int scrollHeight () {get}
scrollLeft                   Property   int scrollLeft () {get} {set}
scrollTop                    Property   int scrollTop () {get} {set}
scrollWidth                  Property   int scrollWidth () {get}
search                       Property   string search () {get} {set}
shape                        Property   string shape () {get} {set}
sourceIndex                  Property   int sourceIndex () {get}
spellcheck                   Property   Variant spellcheck () {get} {set}
style                        Property   IHTMLStyle style () {get}
tabIndex                     Property   short tabIndex () {get} {set}
tagName                      Property   string tagName () {get}
tagUrn                       Property   string tagUrn () {get} {set}
target                       Property   string target () {get} {set}
textContent                  Property   Variant textContent () {get} {set}
title                        Property   string title () {get} {set}
type                         Property   string type () {get} {set}
uniqueID                     Property   string uniqueID () {get}
uniqueNumber                 Property   int uniqueNumber () {get}
urn                          Property   string urn () {get} {set}
xmsAcceleratorKey            Property   string xmsAcceleratorKey () {get} {s...

#>
$text = $element.innerText
write-output $text
try{
  if ($debugPReference -eq 'continue'){
    $attributes = $element.attributes
    $attributes | where-object { $_.name -match 'href'} | select-object -first 1 | format-list
    <#
    # e.g.

    nodeName        : href
    nodeValue       : about:/mozilla/geckodriver/releases/tag/v0.16.0
    specified       : True
    name            : href
    value           : about:/mozilla/geckodriver/releases/tag/v0.16.0
    expando         : False
    nodeType        : 2
    parentNode      :
    childNodes      :
    firstChild      :
    lastChild       :
    previousSibling :
    nextSibling     :
    attributes      :
    ownerDocument   : mshtml.HTMLDocumentClass
    ie8_nodeValue   : /mozilla/geckodriver/releases/tag/v0.16.0
    ie8_value       : /mozilla/geckodriver/releases/tag/v0.16.0
    ie8_specified   : True
    ownerElement    : System.__ComObject
    ie9_nodeValue   : /mozilla/geckodriver/releases/tag/v0.16.0
    ie9_nodeName    : href
    ie9_name        : href
    ie9_value       : /mozilla/geckodriver/releases/tag/v0.16.0
    ie9_firstChild  : System.__ComObject
    ie9_lastChild   : System.__ComObject
    ie9_childNodes  : System.__ComObject
    ie9_specified   : True
    constructor     : System.__ComObject
    prefix          :
    localName       : href
    namespaceURI    :
    textContent     : /mozilla/geckodriver/releases/tag/v0.16.0

    #>
  }
    $href = $element.getAttribute('href',0)
    write-output ($href -replace '^about:','')
    $attributes = $element.attributes
    $attributes | where-object { $_.name -match 'href'} | select-object -first 1 | select-object -property textContent | format-list
    # write-output ($href.textContent)
  } catch [Exception] {
    # ignore
    write-Debug ( 'Exception : ' + $_.Exception.Message)
  }
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
  remove-variable html2

}
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
remove-variable html

# geckodriver better way
$url = 'https://api.github.com/repos/mozilla/geckodriver/releases'
$releases = @{}

$content = (invoke-webrequest -uri $url).Content
$array_obj_json = $content | convertfrom-json
if ($debugPReference -eq 'continue'){
  $obj_json[11] | select-object -property *
}
$array_obj_json | foreach-object {
  $obj_json = $_
  $assets = $obj_json.assets
  $assets | foreach-object {
    $key = $_.browser_download_url
    if ($key -match $plaform ) {
      if ($key -match '/\b(?<version>v[0-9]+\.[0-9]+\.[0-9]+)\b/' ){
        $version = $matches['version']
        $version_key = 0 + ($version -replace '^v','' -replace '.(\d)', '000$1')
        $download_url = $key
        <#
        write-output $download_url
        write-output $version_key
        write-output $version
        #>
        $release_info = @{}
        $release_info['version'] = $version
        $release_info['download_url'] = $download_url
        $releases[$version_key] = $release_info
      }
    }
  }
}
$latest_release = $releases.GetEnumerator() | sort -Property name -descending | select-object -first 1
$latest_release.Value | format-list
exit 0

# ie:
# really ?
$url = 'http://www.seleniumhq.org/download'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = new-object -ComObject 'HTMLFile'

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

# IEDriverServer better way
$url = 'https://selenium-release.storage.googleapis.com/'
$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$o = [xml]$content

$o.'ListBucketResult'.'Contents'[0].'Key'

# 2.39/IEDriverServer_Win32_2.39.0.zip
$download_url = ('{0}{1}' -f $url, $o.'ListBucketResult'.'Contents'[0].'Key')
exit 0

# note no '/' separator in the format - 'invoke-webrequest' is sensitive
# https://selenium-release.storage.googleapis.com//2.39/IEDriverServer_Win32_2.39.0.zip

# To validate, download it
# (invoke-webrequest -url $download_url ).RawContentLength
# 836478

# edge

pushd 'HKLM:/'
cd 'SOFTWARE/Microsoft/Windows NT/CurrentVersion'
$currentBuildNumber = (Get-ItemProperty -Path ('HKLM:/SOFTWARE/Microsoft/Windows NT/CurrentVersion' -f $hive,$path) -Name 'CurrentBuildNumber' -ErrorAction 'SilentlyContinue').CurrentBuildNumber
if ($currentBuildNumber -eq $null ) {
  $currentBuildNumber = '17134'
}
popd

# mocking on Windows 7
$currentBuildNumber = '17134'

write-output ('CurrentBuildNumber: {0}' -f $currentBuildNumber)

$url = 'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver'

$cnt = get-random -maximum 100 -minimum 1
$tmp_file = "${env:TEMP}/a${cnt}.html"
$content = (invoke-webrequest -uri $url).Content
$content | out-file $tmp_file
if ($debugPReference -eq 'continue'){
  dir $tmp_file
}

$html = New-Object -ComObject 'HTMLFile'

# backing up
$source = Get-Content -Path $tmp_file -raw
$html.IHTMLDocument2_write($source)

$html.IHTMLDocument2_write( $content )

$document =  $html.documentElement

$nodes = $document.getelementsByClassName('driver-download')

$html2   = New-Object -ComObject 'HTMLFile'
<#
NOTE:
  $nodes[0].innerhtml
  <P aria-label="WebDriver for Windows Insiders and future Windows releases" class=subtitle>Insiders and future releases</P>
  <P class=driver-download__meta>Microsoft WebDriver is now a Windows Feature on Demand.</P>
  <P class=driver-download__meta>To install run the following in an elevated command prompt:</P>
  <P class=driver-download__meta>DISM.exe /Online /Add-Capability /CapabilityName:Microsoft.WebDriver~~~~0.0.1.0</P>
#>
write-output ('Examine {0} nodes' -f $nodes.length)

$nodes |  foreach-object {
  $node = $_
  $node_html = ($node | select-object -expandproperty 'outerHTML')
  if ($debugPReference -eq 'continue'){
    write-output 'Processing the node HTML:'
    write-output $node_html
  }
  $html2.IHTMLDocument2_write($node_html )

  <#
    # element data sample
    <a class="subtitle"
       href="https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe"
       aria-label="WebDriver for release number 17134">Release 17134</a>
    <p class="driver-download__meta">Version: 6.17134 | Edge version supported: 17.17134 |
  #>

  $elements = $html2.getElementsByTagName('A')

  write-output $elements.length
  0..($elements.length) | foreach-object {
    $cnt = $_
    $element = $elements.item($cnt)

    if ($debugpreference -eq 'continue' ){
      $element
    }
    $element_text = ($element | select-object -expandproperty 'innerText')
    $element_html = ($element | select-object -expandproperty 'outerHTML')
    if ($element_text -match "Release ${currentBuildNumber}") {
      write-output 'Found something'
      write-output 'element inner text: '
      write-output $element_text
      write-output 'element HTML: '
      write-output $element_html
    }
  }
}

$html2.getElementsByTagName('A')[0].href
# e.g. https://download.microsoft.com/download/F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/MicrosoftWebDriver.exe
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html) | out-null
remove-variable html
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($html2) | out-null
remove-variable html2
