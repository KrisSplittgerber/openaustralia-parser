<?php
// This file config.php.incvs is a template config file.
// Edit this, and copy it to a file called config.php.

// *******************************************************************************
// MySQL database.
define ("DB_HOST", "localhost");
define ("DB_USER", "twfy-australia");
define ("DB_PASSWORD", "twfy-australia");
define ("DB_NAME", "twfy-australia");

// *******************************************************************************
// Domains.
// Set this to the domain you are hosting on. If you're running locally, this will be "localhost" 
define ("DOMAIN", "localhost");
define ("COOKIEDOMAIN", "localhost");

// General 'Contact us' type email address. Point this at a real address if you 
// want the site generated email to come to you. Can be overridden for other mails below.

define ("CONTACTEMAIL", "matthew@openaustralia.org");

// File system path to the top directory of this Theyworkforyou installation
define ("BASEDIR","/Library/Webserver/Documents/mysociety/twfy/www/docs"); 

// Webserver path to 'top' directory of the site (possibly just "/"). For example,
// if the site is at 'http://www.yourdomain.com/public/theyworkforyou', 
// this would be '/public/theyworkforyou'
define ("WEBPATH", "/");

// *******************************************************************************
// Stop Here. In a basic developer configuration you shouldn't need to edit 
// anything below this point.
// Feel free to have an explore if you wish though.
// *******************************************************************************

// Variables that are local to this particular set-up.
// Put variables that are consistent across development and live servers in init.php.

// If true, php errors will be displayed, not emailed to the bugs list.
define ("DEVSITE", true);

// Add this and a number to the URL (eg '?debug=1') to view debug info.
define ("DEBUGTAG", 'debug');

// Timezone (only works in PHP5)
define ("TIMEZONE", "Europe/London");

// *******************************************************************************
// If you've unpacked the tar file normally, and set the paths correctly above, 
// you shouldn't change these.

// File system path to where all the include files live.
define ("INCLUDESPATH", BASEDIR . "/../includes/");

// Web path to the directory where the site's images are kept.
define ("IMAGEPATH", WEBPATH . "images/");


// This will be included in data.php. It's an array of page/section metadata.
define ("METADATAPATH", BASEDIR . "/../includes/easyparliament/metadata.php");

// Search related. If defined will use XAPIAN search instead of mysql search
//define ("XAPIANDB", "/home/fawkes/searchdb");

// XML files and other scraped data stored as files
define ("RAWDATA", "/home/fawkes/pwdata");

// Location of the parliamentary recess data file. You can access this remotely 
// from the main theyworkforyou site if you use
define ("RECESSFILE","http://www.theyworkforyou.com/pwdata/parl-recesses.txt");
// AND amend your global php.ini to 'allow_url_fopen = On'
//define ("RECESSFILE", RAWDATA . "/parl-recesses.txt");



// *******************************************************************************
// More Email addresses.

// When a user reports a comment, notification is sent to this address.
define ("REPORTLIST", CONTACTEMAIL);

// All outgoing emails to users get BCC'd to this address.
define ("BCCADDRESS", CONTACTEMAIL);

// All error emails go to this address.
define ("BUGSLIST", CONTACTEMAIL);

// Email addresses that alertmailer.php sends stats to
define('ALERT_STATS_EMAILS', CONTACTEMAIL);

// Postcode lookup
// Not defined on dev copies, causes postcode lookups to be random but deterministic
//define ("POSTCODE_SEARCH_DOMAIN", "www.somedomain.com");
define ("POSTCODE_SEARCH_PORT", "80");
define ("POSTCODE_SEARCH_PATH", "somescript.php?postcode=");


// *******************************************************************************
// mySociety user-tracking.

// Do we add the web-bug image to each page?
define('OPTION_TRACKING', 0);   // off by default

// URL of the web-bug image.
define('OPTION_TRACKING_URL', 'http://path/to/web/bug');

// Shared secret to authenticate against the tracking service.
define('OPTION_TRACKING_SECRET', 'really-secret-value');

// For linking to HFYMP at points
// define('OPTION_AUTH_SHARED_SECRET', '');
// define('OPTION_HEARFROMYOURMP_BASE_URL', '');

// For API getGeometry call.
// define('OPTION_MAPIT_URL', '');

// For seeing if someone is in New Zealand.
// define('OPTION_GAZE_URL', '');

// mySociety debug level thing. Probably leave as 0.
define('OPTION_PHP_DEBUG_LEVEL', 0);

