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
  [string]$browser = 'chrome',
  [string]$base_url = 'http://www.wikipedia.org',
  [string]$script,
  [int]$version,
  [switch]$pause
)

#requires -version 3

# optional : use .net type accelerators assembly to shorten the class paths
# http://poshcode.org/5730
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/07/08/use-powershell-to-find-powershell-type-accelerators.aspx

$type_accelerators = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  Unblock-File -Path $_;
  Add-Type -Path $_ -Passthru |
  Where-Object IsPublic |
  ForEach-Object {
    $loaded_class = $_
    try {
      $type_accelerators::Add($loaded_class.Name,$loaded_class)
      Write-Debug ('Added accelerator {0} for {1}' -f $loaded_class.Name,$loaded_class.FullName)
    } catch {
      ('Failed to add accelerator {0} for {1}' -f $loaded_class.Name,$loaded_class.FullName)
    }
  }
  Write-Debug ('Loaded type: {0} ' -f $_)
}
popd
# NOTE: the following call does not require explicitly launched hub and node processes

Write-Host "Running on ${browser}"
$selenium = $null
if ($browser -match 'firefox') {
  $selenium = New-Object FirefoxDriver

}
elseif ($browser -match 'chrome') {
  $selenium = New-Object ChromeDriver

}
elseif ($browser -match 'ie') {
  $selenium = New-Object InternetExplorerDriver


}
# WARNING: alternative syntax does not work for all types and will not be used
# $selenium = [FirefoxDriver]@{}

$actions = New-Object Actions ($selenium)

$selenium.Navigate().GoToUrl($base_url)
$timespan = [timespan]::FromSeconds(3)
$wait = New-Object WebDriverWait ($selenium,$timespan)
$wait.PollingInterval = 100

try {
  $element = $wait.Until([expectedconditions]::ElementExists([by]::Id('searchInput')))
  $actions.MoveToElement([iwebelement]$element).Build().Perform()
} catch [exception]{
}
Start-Sleep 3
$selenium.Close()
# NOTE: requires  explicitly launching a hub/node
try {
  $hub_url = 'http://127.0.0.1:4444/wd/hub'
  $capabilities = [desiredcapabilities]::Firefox()
  $uri = [System.Uri]$hub_url
  $selenium = New-Object RemoteWebDriver ($uri,$capabilities)
  [void]($selenium.Manage().Timeouts().ImplicitlyWait($timespan))
  $selenium.Navigate().GoToUrl($base_url)
  Start-Sleep 3
  $selenium.Close()

} catch [exception]{
}

<#
IsPublic IsSerial Name                                     BaseType            
-------- -------- ----                                     --------            
True     True     By                                       System.Object       
True     True     Cookie                                   System.Object       
True     False    IFileDetector                                                
True     False    DefaultFileDetector                      System.Object       
True     False    ICommandServer                                               
True     False    DriverService                            System.Object       
True     True     WebDriverException                       System.Exception    
True     True     DriverServiceNotFoundException           OpenQA.Selenium.W...
True     True     ElementNotVisibleException               OpenQA.Selenium.W...
True     False    IAlert                                                       
True     False    IAllowsFileDetection                                         
True     False    ICapabilities                                                
True     False    ICookieJar                                                   
True     False    IHasCapabilities                                             
True     False    IHasInputDevices                                             
True     False    IHasTouchScreen                                              
True     False    IJavaScriptExecutor                                          
True     False    IKeyboard                                                    
True     True     IllegalLocatorException                  OpenQA.Selenium.W...
True     False    ILocatable                                                   
True     False    IMouse                                                       
True     False    INavigation                                                  
True     True     InvalidCookieDomainException             OpenQA.Selenium.W...
True     True     InvalidElementStateException             OpenQA.Selenium.W...
True     True     NotFoundException                        OpenQA.Selenium.W...
True     True     NoSuchElementException                   OpenQA.Selenium.N...
True     True     InvalidSelectorException                 OpenQA.Selenium.N...
True     False    IOptions                                                     
True     False    IRotatable                                                   
True     False    ISearchContext                                               
True     False    ITakesScreenshot                                             
True     False    ITargetLocator                                               
True     False    ITimeouts                                                    
True     False    ITouchScreen                                                 
True     False    IWebDriver                                                   
True     False    IWebElement                                                  
True     False    IWindow                                                      
True     False    Keys                                     System.Object       
True     True     NoAlertPresentException                  OpenQA.Selenium.N...
True     True     NoSuchFrameException                     OpenQA.Selenium.N...
True     True     NoSuchWindowException                    OpenQA.Selenium.N...
True     True     PlatformType                             System.Enum         
True     False    Platform                                 System.Object       
True     True     ProxyKind                                System.Enum         
True     False    Proxy                                    System.Object       
True     True     ScreenOrientation                        System.Enum         
True     True     Screenshot                               System.Object       
True     True     StaleElementReferenceException           OpenQA.Selenium.W...
True     True     UnableToSetCookieException               OpenQA.Selenium.W...
True     True     UnhandledAlertException                  OpenQA.Selenium.W...
True     True     WebDriverResult                          System.Enum         
True     True     WebDriverTimeoutException                OpenQA.Selenium.W...
True     True     XPathLookupException                     OpenQA.Selenium.W...
True     False    IFindsById                                                   
True     False    IFindsByClassName                                            
True     False    IFindsByLinkText                                             
True     False    IFindsByName                                                 
True     False    IFindsByTagName                                              
True     False    IFindsByXPath                                                
True     False    IFindsByPartialLinkText                                      
True     False    IFindsByCssSelector                                          
True     False    RemoteWebDriver                          System.Object       
True     False    ChromeDriver                             OpenQA.Selenium.R...
True     False    ChromeDriverService                      OpenQA.Selenium.D...
True     False    ChromeOptions                            System.Object       
True     False    IWrapsDriver                                                 
True     False    RemoteWebElement                         System.Object       
True     False    ChromeWebElement                         OpenQA.Selenium.R...
True     False    FirefoxBinary                            System.Object       
True     False    FirefoxDriver                            OpenQA.Selenium.R...
True     False    ICommandExecutor                                             
True     False    FirefoxDriverCommandExecutor             System.Object       
True     False    FirefoxDriverServer                      System.Object       
True     False    FirefoxExtension                         System.Object       
True     False    FirefoxProfile                           System.Object       
True     False    FirefoxProfileManager                    System.Object       
True     False    FirefoxWebElement                        OpenQA.Selenium.R...
True     False    InternetExplorerDriver                   OpenQA.Selenium.R...
True     True     InternetExplorerDriverEngine             System.Enum         
True     True     InternetExplorerDriverLogLevel           System.Enum         
True     False    InternetExplorerDriverService            OpenQA.Selenium.D...
True     True     InternetExplorerElementScrollBehavior    System.Enum         
True     True     InternetExplorerUnexpectedAlertBehavior  System.Enum         
True     False    InternetExplorerOptions                  System.Object       
True     False    InternetExplorerWebElement               OpenQA.Selenium.R...
True     False    Actions                                  System.Object       
True     False    IAction                                                      
True     False    ICoordinates                                                 
True     False    TouchActions                             OpenQA.Selenium.I...
True     False    AsyncJavaScriptExecutor                  System.Object       
True     False    IWrapsElement                                                
True     False    ResourceUtilities                        System.Object       
True     False    ReturnedCookie                           OpenQA.Selenium.C...
True     False    PhantomJSDriver                          OpenQA.Selenium.R...
True     False    PhantomJSDriverService                   OpenQA.Selenium.D...
True     False    PhantomJSOptions                         System.Object       
True     False    PhantomJSWebElement                      OpenQA.Selenium.R...
True     False    CapabilityType                           System.Object       
True     False    Command                                  System.Object       
True     False    CommandInfo                              System.Object       
True     False    CommandInfoRepository                    System.Object       
True     False    DesiredCapabilities                      System.Object       
True     False    DriverCommand                            System.Object       
True     False    ErrorResponse                            System.Object       
True     False    LocalFileDetector                        System.Object       
True     False    RemoteTouchScreen                        System.Object       
True     False    Response                                 System.Object       
True     False    SessionId                                System.Object       
True     False    StackTraceElement                        System.Object       
True     False    SafariCommand                            OpenQA.Selenium.R...
True     False    SafariCommandMessage                     System.Object       
True     False    SafariDriver                             OpenQA.Selenium.R...
True     False    SafariDriverCommandExecutor              System.Object       
True     False    SafariDriverConnection                   System.Object       
True     False    SafariDriverExtension                    System.Object       
True     False    SafariDriverServer                       System.Object       
True     False    SafariOptions                            System.Object       
True     False    SafariResponseMessage                    System.Object       
True     False    AcceptEventArgs                          System.EventArgs    
True     False    BinaryMessageHandledEventArgs            System.EventArgs    
True     False    ConnectionEventArgs                      System.EventArgs    
True     False    ErrorEventArgs                           System.EventArgs    
True     True     FrameType                                System.Enum         
True     True     HandshakeException                       System.Exception    
True     False    IHandler                                                     
True     False    ISocket                                                      
True     False    IWebSocketConnection                                         
True     False    IWebSocketConnectionInfo                                     
True     False    IWebSocketServer                                             
True     False    ReceivedEventArgs                        System.EventArgs    
True     False    SocketWrapper                            System.Object       
True     False    StandardHttpRequestReceivedEventArgs     System.EventArgs    
True     False    TextMessageHandledEventArgs              System.EventArgs    
True     False    WebSocketConnection                      System.Object       
True     False    WebSocketConnectionInfo                  System.Object       
True     True     WebSocketException                       System.Exception    
True     False    WebSocketHttpRequest                     System.Object       
True     False    WebSocketServer                          System.Object       
True     False    EventFiringWebDriver                     System.Object       
True     False    FindElementEventArgs                     System.EventArgs    
True     False    WebDriverExceptionEventArgs              System.EventArgs    
True     False    WebDriverNavigationEventArgs             System.EventArgs    
True     False    WebDriverScriptEventArgs                 System.EventArgs    
True     False    WebElementEventArgs                      System.EventArgs    
True     False    WebDriverExtensions                      System.Object       
True     False    ByChained                                OpenQA.Selenium.By  
True     False    ByIdOrName                               OpenQA.Selenium.By  
True     False    CacheLookupAttribute                     System.Attribute    
True     False    IElementLocatorFactory                                       
True     False    DefaultElementLocatorFactory             System.Object       
True     False    FindsByAttribute                         System.Attribute    
True     False    FindsBySequenceAttribute                 System.Attribute    
True     True     How                                      System.Enum         
True     False    PageFactory                              System.Object       
True     False    RetryingElementLocatorFactory            System.Object       
True     False    IWait`1                                                      
True     False    DefaultWait`1                            System.Object       
True     False    ExpectedConditions                       System.Object       
True     False    IClock                                                       
True     False    ILoadableComponent                                           
True     False    LoadableComponent`1                      System.Object       
True     True     LoadableComponentException               OpenQA.Selenium.W...
True     False    PopupWindowFinder                        System.Object       
True     False    SelectElement                            System.Object       
True     False    SlowLoadableComponent`1                  OpenQA.Selenium.S...
True     False    SystemClock                              System.Object       
True     True     UnexpectedTagNameException               OpenQA.Selenium.W...
True     False    WebDriverWait                            OpenQA.Selenium.S...
True     True     ActionTargets                            System.Enum         
True     True     TestDelegate                             System.MulticastD...
True     False    Assert                                   System.Object       
True     False    ConstraintFactory                        System.Object       
True     False    AssertionHelper                          NUnit.Framework.C...
True     False    Assume                                   System.Object       
True     False    CollectionAssert                         System.Object       
True     False    Contains                                 System.Object       
True     False    DirectoryAssert                          System.Object       
True     False    FileAssert                               System.Object       
True     False    GlobalSettings                           System.Object       
True     False    Guard                                    System.Object       
True     False    Has                                      System.Object       
True     False    IExpectException                                             
True     False    Is                                       System.Object       
True     False    ITestCaseData                                                
True     False    Iz                                       NUnit.Framework.Is  
True     False    List                                     System.Object       
True     False    ListMapper                               System.Object       
True     False    Randomizer                               System.Random       
True     True     SpecialValue                             System.Enum         
True     False    StringAssert                             System.Object       
True     False    TestCaseData                             System.Object       
True     False    TestContext                              System.Object       
True     False    TestDetails                              System.Object       
True     True     TestState                                System.Enum         
True     True     TestStatus                               System.Enum         
True     False    Text                                     System.Object       
True     False    MessageWriter                            System.IO.StringW...
True     False    TextMessageWriter                        NUnit.Framework.C...
True     False    Throws                                   System.Object       
True     False    CategoryAttribute                        System.Attribute    
True     False    DatapointAttribute                       System.Attribute    
True     False    DatapointsAttribute                      System.Attribute    
True     False    DescriptionAttribute                     System.Attribute    
True     True     MessageMatch                             System.Enum         
True     False    ExpectedExceptionAttribute               System.Attribute    
True     False    ExplicitAttribute                        System.Attribute    
True     False    IgnoreAttribute                          System.Attribute    
True     False    IncludeExcludeAttribute                  System.Attribute    
True     False    PlatformAttribute                        NUnit.Framework.I...
True     False    CultureAttribute                         NUnit.Framework.I...
True     False    PropertyAttribute                        System.Attribute    
True     False    CombinatorialAttribute                   NUnit.Framework.P...
True     False    PairwiseAttribute                        NUnit.Framework.P...
True     False    SequentialAttribute                      NUnit.Framework.P...
True     False    MaxTimeAttribute                         NUnit.Framework.P...
True     False    ParameterDataAttribute                   System.Attribute    
True     False    ValuesAttribute                          NUnit.Framework.P...
True     False    RandomAttribute                          NUnit.Framework.V...
True     False    RangeAttribute                           NUnit.Framework.V...
True     False    RepeatAttribute                          NUnit.Framework.P...
True     False    RequiredAddinAttribute                   System.Attribute    
True     False    SetCultureAttribute                      NUnit.Framework.P...
True     False    SetUICultureAttribute                    NUnit.Framework.P...
True     False    SetUpAttribute                           System.Attribute    
True     False    SetUpFixtureAttribute                    System.Attribute    
True     False    SuiteAttribute                           System.Attribute    
True     False    TearDownAttribute                        System.Attribute    
True     False    ITestAction                                                  
True     False    TestActionAttribute                      System.Attribute    
True     False    TestAttribute                            System.Attribute    
True     False    TestCaseAttribute                        System.Attribute    
True     False    TestCaseSourceAttribute                  System.Attribute    
True     False    TestFixtureAttribute                     System.Attribute    
True     False    TestFixtureSetUpAttribute                System.Attribute    
True     False    TestFixtureTearDownAttribute             System.Attribute    
True     False    TheoryAttribute                          System.Attribute    
True     False    TimeoutAttribute                         NUnit.Framework.P...
True     False    RequiresSTAAttribute                     NUnit.Framework.P...
True     False    RequiresMTAAttribute                     NUnit.Framework.P...
True     False    RequiresThreadAttribute                  NUnit.Framework.P...
True     False    ValueSourceAttribute                     System.Attribute    
True     False    IResolveConstraint                                           
True     False    Constraint                               System.Object       
True     False    PrefixConstraint                         NUnit.Framework.C...
True     False    AllItemsConstraint                       NUnit.Framework.C...
True     False    BinaryConstraint                         NUnit.Framework.C...
True     False    AndConstraint                            NUnit.Framework.C...
True     False    TypeConstraint                           NUnit.Framework.C...
True     False    AssignableFromConstraint                 NUnit.Framework.C...
True     False    AssignableToConstraint                   NUnit.Framework.C...
True     False    AttributeConstraint                      NUnit.Framework.C...
True     False    AttributeExistsConstraint                NUnit.Framework.C...
True     False    BasicConstraint                          NUnit.Framework.C...
True     False    BinarySerializableConstraint             NUnit.Framework.C...
True     False    CollectionConstraint                     NUnit.Framework.C...
True     False    CollectionItemsEqualConstraint           NUnit.Framework.C...
True     False    CollectionContainsConstraint             NUnit.Framework.C...
True     False    CollectionEquivalentConstraint           NUnit.Framework.C...
True     False    CollectionOrderedConstraint              NUnit.Framework.C...
True     False    CollectionSubsetConstraint               NUnit.Framework.C...
True     False    CollectionTally                          System.Object       
True     False    ComparisonAdapter                        System.Object       
True     False    ComparisonConstraint                     NUnit.Framework.C...
True     True     ActualValueDelegate`1                    System.MulticastD...
True     False    ConstraintBuilder                        System.Object       
True     False    ConstraintExpressionBase                 System.Object       
True     False    ConstraintExpression                     NUnit.Framework.C...
True     False    ContainsConstraint                       NUnit.Framework.C...
True     False    DelayedConstraint                        NUnit.Framework.C...
True     False    EmptyCollectionConstraint                NUnit.Framework.C...
True     False    EmptyConstraint                          NUnit.Framework.C...
True     False    EmptyDirectoryConstraint                 NUnit.Framework.C...
True     False    EmptyStringConstraint                    NUnit.Framework.C...
True     False    StringConstraint                         NUnit.Framework.C...
True     False    EndsWithConstraint                       NUnit.Framework.C...
True     False    EqualConstraint                          NUnit.Framework.C...
True     False    EqualityAdapter                          System.Object       
True     False    ExactCountConstraint                     NUnit.Framework.C...
True     False    ExactTypeConstraint                      NUnit.Framework.C...
True     False    ExceptionTypeConstraint                  NUnit.Framework.C...
True     False    FailurePoint                             System.Object       
True     False    FalseConstraint                          NUnit.Framework.C...
True     False    FloatingPointNumerics                    System.Object       
True     False    GreaterThanConstraint                    NUnit.Framework.C...
True     False    GreaterThanOrEqualConstraint             NUnit.Framework.C...
True     False    InstanceOfTypeConstraint                 NUnit.Framework.C...
True     False    LessThanConstraint                       NUnit.Framework.C...
True     False    LessThanOrEqualConstraint                NUnit.Framework.C...
True     False    MsgUtils                                 System.Object       
True     False    NaNConstraint                            NUnit.Framework.C...
True     False    NoItemConstraint                         NUnit.Framework.C...
True     False    NotConstraint                            NUnit.Framework.C...
True     False    NullConstraint                           NUnit.Framework.C...
True     False    NullOrEmptyStringConstraint              NUnit.Framework.C...
True     False    Numerics                                 System.Object       
True     False    NUnitComparer                            System.Object       
True     False    NUnitComparer`1                          System.Object       
True     False    INUnitEqualityComparer                                       
True     False    NUnitEqualityComparer                    System.Object       
True     False    OrConstraint                             NUnit.Framework.C...
True     False    PathConstraint                           NUnit.Framework.C...
True     False    PredicateConstraint`1                    NUnit.Framework.C...
True     False    PropertyConstraint                       NUnit.Framework.C...
True     False    PropertyExistsConstraint                 NUnit.Framework.C...
True     False    RangeConstraint`1                        NUnit.Framework.C...
True     False    RegexConstraint                          NUnit.Framework.C...
True     False    ResolvableConstraintExpression           NUnit.Framework.C...
True     False    ReusableConstraint                       System.Object       
True     False    SameAsConstraint                         NUnit.Framework.C...
True     False    SamePathConstraint                       NUnit.Framework.C...
True     False    SamePathOrUnderConstraint                NUnit.Framework.C...
True     False    SomeItemsConstraint                      NUnit.Framework.C...
True     False    StartsWithConstraint                     NUnit.Framework.C...
True     False    SubPathConstraint                        NUnit.Framework.C...
True     False    SubstringConstraint                      NUnit.Framework.C...
True     False    ThrowsConstraint                         NUnit.Framework.C...
True     False    ThrowsNothingConstraint                  NUnit.Framework.C...
True     False    Tolerance                                System.Object       
True     True     ToleranceMode                            System.Enum         
True     False    TrueConstraint                           NUnit.Framework.C...
True     False    UniqueItemsConstraint                    NUnit.Framework.C...
True     False    XmlSerializableConstraint                NUnit.Framework.C...
True     False    ConstraintOperator                       System.Object       
True     False    PrefixOperator                           NUnit.Framework.C...
True     False    CollectionOperator                       NUnit.Framework.C...
True     False    AllOperator                              NUnit.Framework.C...
True     False    BinaryOperator                           NUnit.Framework.C...
True     False    AndOperator                              NUnit.Framework.C...
True     False    SelfResolvingOperator                    NUnit.Framework.C...
True     False    AttributeOperator                        NUnit.Framework.C...
True     False    ExactCountOperator                       NUnit.Framework.C...
True     False    NoneOperator                             NUnit.Framework.C...
True     False    NotOperator                              NUnit.Framework.C...
True     False    OrOperator                               NUnit.Framework.C...
True     False    PropOperator                             NUnit.Framework.C...
True     False    SomeOperator                             NUnit.Framework.C...
True     False    ThrowsOperator                           NUnit.Framework.C...
True     False    WithOperator                             NUnit.Framework.C...
True     True     AssertionException                       System.Exception    
True     True     IgnoreException                          System.Exception    
True     True     InconclusiveException                    System.Exception    
True     True     SuccessException                         System.Exception    
True     False    INUnitEqualityComparer`1                                     


#>
