#!/usr/bin/perl
#===============================================================================

use strict;
use warnings;

use Selenium::Remote::Driver;
use Selenium::Remote::Commands;
use Selenium::Remote::WebElement;
use Selenium::Chrome;
use HTML::Parser::Simple;
use Data::Dumper;
use Time::Hires qw(sleep usleep);
use JSON;
our (
    $base_url,    $driver, $element, $css_selector, $xpath,
    $html_parser, $data,   $script,  $result
);

$base_url = 'http://www.carnival.com/';

# $driver   = Selenium::Chrome->new(binary=>"c:/Program Files/Google/Chrome/Application/chrome.exe");
# Unable to connect to the ...chrome.exe binary on port 9515 at C:/Perl/site/lib/Selenium/CanStartBinary.pm line 126

# fallback to regular
$driver = Selenium::Chrome->new;
$driver->get($base_url);

$script = join '', <DATA>;

$result = $driver->execute_script($script);

# The result is already a Perl object - no JSON module call required
print Dumper($result);

$driver->quit();
exit(0);

__DATA__
var ua = window.navigator.userAgent;


if (ua.match(/PhantomJS/)) { 
return 'Cannot measure on '+ ua;
}
else{
var performance = 
      window.performance || 
      window.mozPerformance || 
      window.msPerformance || 
      window.webkitPerformance || {}; 
// var timings = performance.timing || {};
// return timings;
// NOTE:  performance.timing will not return anything with Chrome
// timing is returned by FF
// timing is returned by Phantom
var network = performance.getEntries() || {}; 
 return network;
}

