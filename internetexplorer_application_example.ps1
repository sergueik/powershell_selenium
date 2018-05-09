# based on: http://forum.oszone.net/thread-334713.html
$s = new-object -com 'interneteplorer.application'
$s.visible = $true
$target_url = 'https://tickets.ifa.com/Services/ADService.html?lang=ru'
$s.navigate2($target_url)
$s.ReadyState # 4
$s.Busy # False
$m1 = $s.document.getElemetsByClassName('header')

<#
 $m1 | get-member

   TypeName: System.__ComObject#{3050f50c-98b5-11cf-bb82-00aa00bdce0b}

Name                         MemberType Definition
----                         ---------- ----------
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
align                        Property   string align () {get} {set}
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
childNodes                   Property   IDispatch childNodes () {get}
children                     Property   IDispatch children () {get}
className                    Property   string className () {get} {set}
clientHeight                 Property   int clientHeight () {get}
clientLeft                   Property   int clientLeft () {get}
clientTop                    Property   int clientTop () {get}
clientWidth                  Property   int clientWidth () {get}
constructor                  Property   IDispatch constructor () {get}
contentEditable              Property   string contentEditable () {get} {set}
currentStyle                 Property   IHTMLCurrentStyle currentStyle () {g...
dataFld                      Property   string dataFld () {get} {set}
dataFormatAs                 Property   string dataFormatAs () {get} {set}
dataSrc                      Property   string dataSrc () {get} {set}
dir                          Property   string dir () {get} {set}
disabled                     Property   bool disabled () {get} {set}
document                     Property   IDispatch document () {get}
filters                      Property   IHTMLFiltersCollection filters () {g...
firstChild                   Property   IHTMLDOMNode firstChild () {get}
hideFocus                    Property   bool hideFocus () {get} {set}
id                           Property   string id () {get} {set}
ie8_attributes               Property   IHTMLAttributeCollection3 ie8_attrib...
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
namespaceURI                 Property   Variant namespaceURI () {get}
nextSibling                  Property   IHTMLDOMNode nextSibling () {get}
nodeName                     Property   string nodeName () {get}
nodeType                     Property   int nodeType () {get}
nodeValue                    Property   Variant nodeValue () {get} {set}
noWrap                       Property   bool noWrap () {get} {set}
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
prefix                       Property   Variant prefix () {get} {set}
previousSibling              Property   IHTMLDOMNode previousSibling () {get}
readyState                   Property   Variant readyState () {get}
recordNumber                 Property   Variant recordNumber () {get}
role                         Property   string role () {get} {set}
runtimeStyle                 Property   IHTMLStyle runtimeStyle () {get}
scopeName                    Property   string scopeName () {get}
scrollHeight                 Property   int scrollHeight () {get}
scrollLeft                   Property   int scrollLeft () {get} {set}
scrollTop                    Property   int scrollTop () {get} {set}
scrollWidth                  Property   int scrollWidth () {get}
sourceIndex                  Property   int sourceIndex () {get}
spellcheck                   Property   Variant spellcheck () {get} {set}
style                        Property   IHTMLStyle style () {get}
tabIndex                     Property   short tabIndex () {get} {set}
tagName                      Property   string tagName () {get}
tagUrn                       Property   string tagUrn () {get} {set}
textContent                  Property   Variant textContent () {get} {set}
title                        Property   string title () {get} {set}
uniqueID                     Property   string uniqueID () {get}
uniqueNumber                 Property   int uniqueNumber () {get}
xmsAcceleratorKey            Property   string xmsAcceleratorKey () {get} {s...

#>

$e1 = $m1[1]
$e1.nodeName # DIV
$e1.textContent # ???? 02 - ?????? : ??????? - ????????????
$e1.parentNode

$e2 = $e1.parentNode
$e2.innerHTML

# <div class="header" ng-bind="product.productName">???? 02 -?????? : ??????? - ????????????</div>

$e3 = $e2.parentNode

$e4 = $e3.NextSibling.NextSibling


$e4.textContent
#     CAT 1
#     CAT 2
#     CAT 3
#     CAT 4

$m2 = $e4.getElementsByClassName('categoryBox')
$m2[1]
$m2[1].innerHTML
# CAT 2
$m2[1].outerHTML
# <div class="categoryBox zeroAvailability" ng-bind="cat.categoryName" ng-class="cat.availabilityColor">CAT 2</div>


$m2[1].getAttribute('ng-class')
# cat.availabilityColor

# TODO: https://stackoverflow.com/questions/3514945/running-a-javascript-function-in-an-instance-of-internet-explorer?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

$doc = $s.Document;
[mshtml.IHTMLWindow2] $win = $doc.parentWindow

[mshtml.IHTMLWindow2] $win = [mshtml.IHTMLWindow2]$doc.parentWindow
Cannot convert the "System.__ComObject" value of type "System.__ComObject#{3050f55d-98b5-11cf-bb82-00aa00bdce0b}" to type "mshtml.IHTMLWindow2".
$doc.parentWindow.execScript("alert('Arbitrary javascript code')", "javascript");
# will pop up the Alert on IE