#!/usr/bin/perl
#===============================================================================
package GetDestinations;
use strict;
use warnings;

use Selenium::Remote::Driver;
use Selenium::Remote::Commands;
use Selenium::Remote::WebElement;
use HTML::Parser::Simple;
use base 'HTML::Parser';
use Data::Dumper;
use Time::Hires qw(sleep usleep);
use JSON;

our ( $base_url, $driver, $element, $css_selector, $xpath, $html_parser,
    $data );

our (
    $processing_destination, $destination_text, $destination_data_val,
    $destination_href,       $destinations
);

sub start {
    my ( $self, $tag, $attr, $attrseq, $origtext ) = @_;
    if ( $tag =~ /^a$/i && $attr->{'href'} =~ /\bshore-excursions\b/i ) {
        $destination_data_val = $attr->{'data-val'};
        $destination_href     = $attr->{'href'};

        $processing_destination = 1;
    }
}

sub text {
    my ( $self, $text ) = @_;
    if ($processing_destination) { $destination_text = $text; }
}

sub end {
    my ( $self, $tag, $origtext ) = @_;

    # reset appropriate flag if we leave </a>
    if ( $tag =~ /^a$/i ) {
        if ( defined($destination_data_val) ) {
            $destinations->{$destination_data_val} = {
                text     => $destination_text,
                href     => $destination_href,
                data_val => $destination_data_val
            };
            $destination_text     = undef;
            $destination_href     = undef;
            $destination_data_val = undef;
        }
        $processing_destination = 0;
    }

}

$base_url = 'http://www.carnival.com/';
$driver   = Selenium::Remote::Driver->new;
$driver->get($base_url);

print STDERR 'Title: ' . $driver->get_title();

$css_selector = 'a.logo';
$element = $driver->find_element( $css_selector, 'css' );
print STDERR "Inner html:\n" . $element->get_attribute('innerHTML') . "\n";

# need to hover over one more element to see the floating

my $select_name = 'explore';
$css_selector = "a[class*=canHover][data-ccl-flyout='$select_name']";
$element = $driver->find_element( $css_selector, 'css' );

# print STDERR $driver->get_text($css_selector);
$driver->mouse_move_to_location( element => $element );

# NOTE - sensitive to timeout
sleep(1.0);

my $link_alt_text = 'Shore Excursions';

$xpath = "//img[\@alt='$link_alt_text']";

# this one uses xpath
$element = $driver->find_element_by_xpath($xpath);
$driver->mouse_move_to_location( element => $element );
print STDERR $element->get_attribute('alt');
$element->click();
sleep(0.1);

my $data_target = '#destinationModal';
$css_selector =
  "button[class*='ca-primary-button'][data-target='$data_target']";
$element = $driver->find_element( $css_selector, 'css' );

$driver->mouse_move_to_location( element => $element );
$element->click();

# $driver->mouse_move_to_location(element => $element);
sleep(0.1);

my $destination_container_css_selector = 'div#destinations';
$css_selector = $destination_container_css_selector;
$element = $driver->find_element( $css_selector, 'css' );
my $html_data = $element->get_attribute('innerHTML');
#  $html_data = join( "\n", <DATA> );
sleep(0.1);
$driver->quit();

$destinations = { undef => undef };

my $html_parser = new GetDestinations;
$html_parser->parse($html_data);
my $line = undef;
foreach $line ( split /\n/, $html_data ) {
    $html_parser->parse($line);
}
$html_parser->eof;
print Dumper ( \$destinations );
exit 0;

__DATA__

  <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
    <ul>
      <li class="ca-home-destination-title">
        <span>Departure Ports</span>
      </li>
      <li>
        <a href="/shore-excursions/athens-greece" data-val="ATH">Athens, Greece</a>
      </li>
      <li>
        <a href="/shore-excursions/baltimore-md" data-val="BWI">Baltimore, MD</a>
      </li>
      <li>
        <a href="/shore-excursions/barbados" data-val="BDS">Barbados</a>
      </li>
      <li>
        <a href="/shore-excursions/barcelona-spain" data-val="BCN">Barcelona, Spain</a>
      </li>
      <li>
        <a href="/shore-excursions/charleston-sc" data-val="CHS">Charleston, SC</a>
      </li>
      <li>
        <a href="/shore-excursions/galveston-tx" data-val="GAL">Galveston, TX</a>
      </li>
      <li>
        <a href="/shore-excursions/honolulu-hi" data-val="HNL">Honolulu, HI</a>
      </li>
      <li>
        <a href="/shore-excursions/jacksonville-fl" data-val="JAX">Jacksonville, FL</a>
      </li>
      <li>
        <a href="/shore-excursions/miami-fl" data-val="MIA">Miami, FL</a>
      </li>
      <li>
        <a href="/shore-excursions/new-orleans-la" data-val="MSY">New Orleans, LA</a>
      </li>
      <li>
        <a href="/shore-excursions/new-york-ny" data-val="NYC">New York, NY</a>
      </li>
      <li>
        <a href="/shore-excursions/port-canaveral-orlando-fl" data-val="PCV">Port Canaveral (Orlando), FL</a>
      </li>
      <li>
        <a href="/shore-excursions/san-juan-puerto-rico" data-val="SJU">San Juan, Puerto Rico</a>
      </li>
      <li>
        <a href="/shore-excursions/seattle-wa" data-val="SEA">Seattle, WA</a>
      </li>
      <li>
        <a href="/shore-excursions/tampa-fl" data-val="TPA">Tampa, FL</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/alaska" data-val="A">Alaska</a>
      </li>
      <li>
        <a href="/shore-excursions/juneau-ak" data-val="JNU">Juneau</a>
      </li>
      <li>
        <a href="/shore-excursions/ketchikan-ak" data-val="KTN">Ketchikan</a>
      </li>
      <li>
        <a href="/shore-excursions/skagway-ak" data-val="SKY">Skagway</a>
      </li>
      <li>
        <a href="/shore-excursions/victoria-bc-canada" data-val="YYJ">Victoria</a>
      </li>
    </ul>
  </div>
  <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
    <ul>
      <li class="ca-home-destination-title">
        <a href="/shore-excursions/bahamas" data-val="BH">Bahamas</a>
      </li>
      <li>
        <a href="/shore-excursions/freeport-the-bahamas" data-val="FPO">Freeport</a>
      </li>
      <li>
        <a href="/shore-excursions/grand-turk" data-val="GDT">Grand Turk</a>
      </li>
      <li>
        <a href="/shore-excursions/half-moon-cay-the-bahamas" data-val="HMC">Half Moon Cay</a>
      </li>
      <li>
        <a href="/shore-excursions/nassau-the-bahamas" data-val="NAS">Nassau</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/bermuda" data-val="BM">Bermuda</a>
      </li>
      <li>
        <a href="/shore-excursions/bermuda" data-val="WRF">Bermuda</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/caribbean" data-val="C">Caribbean</a>
      </li>
      <li>
        <a href="/shore-excursions/amber-cove-dominican-republic" data-val="DOP">Amber Cove</a>
      </li>
      <li>
        <a href="/shore-excursions/antigua" data-val="ATG">Antigua</a>
      </li>
      <li>
        <a href="/shore-excursions/aruba" data-val="ARB">Aruba</a>
      </li>
      <li>
        <a href="/shore-excursions/belize" data-val="BZE">Belize</a>
      </li>
      <li>
        <a href="/shore-excursions/bonaire" data-val="BON">Bonaire                       </a>
      </li>
      <li>
        <a href="/shore-excursions/colon-panama" data-val="CLN">Colon</a>
      </li>
      <li>
        <a href="/shore-excursions/curacao" data-val="CUR">Curacao</a>
      </li>
      <li>
        <a href="/shore-excursions/dominica" data-val="DOM">Dominica</a>
      </li>
      <li>
        <a href="/shore-excursions/falmouth-jamaica" data-val="FJM">Falmouth</a>
      </li>
      <li>
        <a href="/shore-excursions/grand-cayman-cayman-islands" data-val="CAY">Grand Cayman</a>
      </li>
      <li>
        <a href="/shore-excursions/grenada" data-val="JGU">Grenada</a>
      </li>
      <li>
        <a href="/shore-excursions/la-romana-dominican-republic" data-val="LRM">La Romana</a>
      </li>
    </ul>
  </div>
  <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
    <ul>
      <li>
        <a href="/shore-excursions/limon-costa-rica" data-val="LMO">Limon</a>
      </li>
      <li>
        <a href="/shore-excursions/mahogany-bay-isla-roatan" data-val="RTN">Mahogany Bay</a>
      </li>
      <li>
        <a href="/shore-excursions/martinique-fwi" data-val="MTK">Martinique</a>
      </li>
      <li>
        <a href="/shore-excursions/montego-bay-jamaica" data-val="MTB">Montego Bay</a>
      </li>
      <li>
        <a href="/shore-excursions/ocho-rios-jamaica" data-val="OCJ">Ocho Rios</a>
      </li>
      <li>
        <a href="/shore-excursions/key-west-fl" data-val="KEY">Key West</a>
      </li>
      <li>
        <a href="/shore-excursions/st-croix-usvi" data-val="STX">St. Croix</a>
      </li>
      <li>
        <a href="/shore-excursions/st-thomas-usvi" data-val="STT">St. Thomas</a>
      </li>
      <li>
        <a href="/shore-excursions/st-kitts-wi" data-val="STK">St Kitts</a>
      </li>
      <li>
        <a href="/shore-excursions/st-maarten-na" data-val="SXM">St. Maarten</a>
      </li>
      <li>
        <a href="/shore-excursions/tortola-british-virgin-islands" data-val="TOR">Tortola</a>
      </li>
      <li>
        <a href="/shore-excursions/ft-lauderdale-pt-evrglds-fl" data-val="EGL">Ft Lauderdale (Pt Evrglds)</a>
      </li>
      <li>
        <a href="/shore-excursions/st-lucia" data-val="SLC">St. Lucia</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/europe" data-val="E">Europe</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/hawaii" data-val="H">Hawaii</a>
      </li>
      <li>
        <a href="/shore-excursions/hilo-hi" data-val="ITO">Hilo</a>
      </li>
      <li>
        <a href="/shore-excursions/kona-hi" data-val="KOA">Kona</a>
      </li>
      <li>
        <a href="/shore-excursions/kauai-nawiliwili-hi" data-val="LIH">Kauai (Nawiliwili)</a>
      </li>
      <li>
        <a href="/shore-excursions/maui-kahului-hi" data-val="OGG">Maui (Kahului)</a>
      </li>
    </ul>
  </div>
  <div class="ca-home-modal-list-container ca-home-modal-list-destination col-sm-3">
    <ul>
      <li class="ca-home-destination-title">
        <a href="/shore-excursions/mexico" data-val="M">Mexico</a>
      </li>
      <li>
        <a href="/shore-excursions/cabo-san-lucas-mexico" data-val="CSL">Cabo San Lucas</a>
      </li>
      <li>
        <a href="/shore-excursions/puerto-vallarta-mexico" data-val="PVR">Puerto Vallarta</a>
      </li>
      <li>
        <a href="/shore-excursions/catalina-island-ca" data-val="CAT">Catalina Island</a>
      </li>
      <li>
        <a href="/shore-excursions/mazatlan-mexico" data-val="MZT">Mazatlan</a>
      </li>
      <li>
        <a href="/shore-excursions/los-angeles-long-beach-ca" data-val="LGB">Los Angeles (Long Beach)</a>
      </li>
      <li>
        <a href="/shore-excursions/manzanillo-mexico" data-val="MAN">Manzanillo</a>
      </li>
      <li>
        <a href="/shore-excursions/ensenada-mexico" data-val="ENS">Ensenada</a>
      </li>
      <li>
        <a href="/shore-excursions/cozumel-mexico" data-val="CZM">Cozumel</a>
      </li>
      <li>
        <a href="/shore-excursions/costa-maya-mexico" data-val="CMZ">Costa Maya</a>
      </li>
      <li>
        <a href="/shore-excursions/yucatan-progreso-mexico" data-val="PGR">Yucatan (Progreso)</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/canada-new-england" data-val="NN">Canada / New England</a>
      </li>
      <li>
        <a href="/shore-excursions/boston-ma" data-val="BOS">Boston</a>
      </li>
      <li>
        <a href="/shore-excursions/portland-me" data-val="PWM">Portland</a>
      </li>
      <li>
        <a href="/shore-excursions/halifax-ns-canada" data-val="YHZ">Halifax</a>
      </li>
      <li>
        <a href="/shore-excursions/saint-john-nb-canada" data-val="YSJ">Saint John</a>
      </li>
      <li class="ca-home-destination-title ca-home-destination-list-row">
        <a href="/shore-excursions/south-america" data-val="S">South America</a>
      </li>
      <li>
        <a href="/shore-excursions/santa-marta-colombia" data-val="SRT">Santa Marta</a>
      </li>
    </ul>
  </div>
