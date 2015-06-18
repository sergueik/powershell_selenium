#!/usr/bin/perl
#===============================================================================

use strict;
use warnings;

use Selenium::Remote::Driver;
use Selenium::Remote::Commands;
use Selenium::Remote::WebElement;
use Selenium::Chrome;
use Selenium::Firefox;

use HTML::Parser::Simple;
use Data::Dumper;
use Time::Hires qw(sleep usleep);
use Getopt::Long;
use JSON;
use Cwd qw(abs_path);
use FindBin;

BEGIN {
    unshift @INC, "$FindBin::Bin/../lib";
}

our (
    $browser,     $debug,   $verbose,      $base_url,
    $selenium,    $element, $css_selector, $xpath,
    $html_parser, $data,    $script,       $result
);

GetOptions(
    "browser=s"  => \$browser,
    "base_url=s" => \$base_url,
    "debug"      => \$debug,
    "verbose"    => \$verbose
) or die("Error in command line arguments\n");
$browser  ||= 'chrome';
$base_url ||= 'http://www.carnival.com/';

# $selenium   = Selenium::Chrome->new(binary=>"c:/Program Files/Google/Chrome/Application/chrome.exe");
# Unable to connect to the ...chrome.exe binary on port 9515 at C:/Perl/site/lib/Selenium/CanStartBinary.pm line 126

# fallback to regular
if ( $browser =~ /chrome/i ) {
    $selenium = Selenium::Chrome->new;
}
elsif ( $browser =~ /firefox/i ) {
    $selenium = Selenium::Firefox->new;
}
if ( not defined $selenium ) {
    die( 'Unknown driver requested: ' . $browser );
}
$selenium->get($base_url);

$script = join '', <DATA>;

$result = $selenium->execute_script($script);

# The result is already a Perl object - no JSON module call required
print Dumper($result);

$selenium->quit();
exit(0);

__DATA__
var ua = window.navigator.userAgent;
if (ua.match(/PhantomJS/)) {
    return [{}];
} else {
    var performance =
        window.performance ||
        window.mozPerformance ||
        window.msPerformance ||
        window.webkitPerformance || {};

    if (ua.match(/Chrome/)) {
        var network = performance.getEntries() || {};
        return network;
    } else {
        var timings = performance.timing || {};
        return [timings];
    }
}

