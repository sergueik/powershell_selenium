#!/usr/bin/perl
#===============================================================================

use strict;
use warnings;

use Selenium::Remote::Driver;
use Selenium::Remote::Commands;
use Selenium::Remote::WebElement;
use HTML::Parser;
use Data::Dumper;

our ( $base_url, $driver, $element, $css_selector, $xpath , $html_parser);

$base_url = 'http://www.carnival.com/';
$driver   = Selenium::Remote::Driver->new;
$driver->get($base_url);

print STDERR 'Title: ' . $driver->get_title();

$css_selector = 'a.logo';
$element = $driver->find_element( $css_selector, 'css' );
print STDERR "Inner html:\n" . $element->get_attribute('innerHTML') . "\n";

# need to hover over one more element to see the floating

my $select_name   = 'explore';
$css_selector = "a[class*=canHover][data-ccl-flyout='$select_name']";
$element = $driver->find_element( $css_selector, 'css' );

# print STDERR $driver->get_text($css_selector);
$driver->mouse_move_to_location( element => $element );

# Time::Hires
sleep 1;

my $link_alt_text = 'Shore Excursions';

$xpath = "//img[\@alt='$link_alt_text']";

# this one uses xpath
$element = $driver->find_element_by_xpath($xpath);
$driver->mouse_move_to_location(element => $element);
print STDERR $element->get_attribute('alt');
$element->click();
sleep 1;

my $data_target = '#destinationModal';
$css_selector =
  "button[class*='ca-primary-button'][data-target='$data_target']";
$element = $driver->find_element( $css_selector, 'css' );

$driver->mouse_move_to_location( element => $element );
$element->click();

# $driver->mouse_move_to_location(element => $element);
sleep 1;


my $destination_container_css_selector = 'div#destinations' ;
$css_selector  = $destination_container_css_selector ;
$element = $driver->find_element( $css_selector, 'css' );
my $html_data = $element->get_attribute('innerHTML');
$html_parser = HTML::Parser->new;
$html_parser->parse($html_data);

sleep 1;


$driver->quit();

