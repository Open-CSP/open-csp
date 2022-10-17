<?php
// Please fill in your page name here:
$wgSitename = "CSP Wiki";

// Elasticsearch
$GLOBALS['smwgElasticsearchEndpoints'] =
	[ 'localhost:9200', ];
$GLOBALS['smwgElasticsearchConfig']['settings']['data'] =
	[
		'number_of_shards' => 2,
		'number_of_replicas' => 0
	];

// Allow uploads
$wgEnableUploads = true;
// Under evaluation: Might no longer be required for WSForm
$wgAllowCopyUploads = true;
$wgCopyUploadsFromSpecialUpload = true;

// Use img_auth.php for all files served.
$wgUploadPath = "/img_auth.php";

// Switch off cache
$wgCachePages = false;
$wgMainCacheType = CACHE_NONE;
$wgCacheDirectory = false;
$wgParserCacheType = CACHE_NONE;

// Enable ElasticSearch as the standard backend
$smwgDefaultStore = 'SMWElasticStore';

// Explicitly set wgRawHtml to false, since it is unsafe.
$wgRawHtml = false;

// No need to patrol pages
$wgUseRCPatrol = false;
$wgUseNPPatrol = false;

// Private wiki
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createaccount'] = false;

// Give read and write rights to all registered users.
$wgGroupPermissions['user']['read'] = true;
$wgGroupPermissions['user']['edit'] = true;
// Give a faux permission to 'moderator' so it will show up as a role.
$wgGroupPermissions['moderator']['read'] = true;

// Allow moderators edit access to the Wiki namespace.
$wgNamespaceProtection[NS_PROJECT] = [ 'edit project' ];
$wgGroupPermissions['sysop']['edit project'] = true;
$wgGroupPermissions['moderator']['edit project'] = true;

// Add messages for login button
$wgMessagesDirs[ 'CSP Basis' ] = __DIR__ . '/../skin/i18n';

##### Admin Links
wfLoadExtension( 'AdminLinks' );

##### CSPResources
wfLoadExtension( 'CSPResources' );
$wgCSPShowSmwIndicator = false;

##### DisplayTitle
wfLoadExtension( 'DisplayTitle' );
// defaults to true
$wgAllowDisplayTitle = true;
// defaults to true
$wgRestrictDisplayTitle = false;

##### FlexForm (formerly: WSForm)
wfLoadExtension( 'FlexForm' );
$wgFlexFormConfig['secure'] = false;
$wgFlexFormConfig['auto_save_interval'] = 30000;
$wgFlexFormConfig['auto_save_after_change'] = 3000;
$wgFlexFormConfig['FlexFormDefaultTheme'] = "plain";
$wgFlexFormConfig['rc_site_key'] = "";
$wgFlexFormConfig['rc_secret_key'] = "";

### Set this to true to use the debug mode of FlexForm
#$wgFlexFormConfig['debug'] = true;

##### Lockdown
wfLoadExtension( 'Lockdown' );

##### WSArrays
wfLoadExtension( 'WSArrays' );
$wfEnableResultPrinter = true;

##### MultimediaViewer
wfLoadExtension( 'MultimediaViewer' );
$wgMediaViewerIsInBeta = true;

##### MyVariables
wfLoadExtension( 'MyVariables' );

##### NumberFormat
require_once "$IP/extensions/NumberFormat/NumberFormat.php";

##### PageSync
wfLoadExtension( 'PageSync' );
$wgPageSync['filePath'] = $IP . '/wsps';

##### ParserFunctions
wfLoadExtension( 'ParserFunctions' );
$wgPFEnableStringFunctions = true;
$wgPFStringLengthLimit = 80000;

##### RegexFun
require_once $IP . '/extensions/RegexFun/RegexFun.php';

##### ReplaceText
wfLoadExtension( 'ReplaceText' );

##### SemanticMediaWiki
enableSemantics( 'wikibase.nl' );
$smwgConfigFileDir = $IP . '/cache';
# Default disabled (CSP Basis#13)
$smwgCheckForConstraintErrors = SMW_CONSTRAINT_ERR_CHECK_NONE;
const NS_WIDGET = 274;
const NS_WIDGET_TALK = 275;
$smwgNamespacesWithSemanticLinks[NS_TEMPLATE] = true;
$smwgNamespacesWithSemanticLinks[SMW_NS_PROPERTY] = true;
$smwgNamespacesWithSemanticLinks[SMW_NS_CONCEPT] = true;
$smwgNamespacesWithSemanticLinks[NS_WIDGET] = true;
$smwgNamespacesWithSemanticLinks[SMW_NS_PROPERTY_TALK] = false;
$smwgNamespacesWithSemanticLinks[SMW_NS_CONCEPT_TALK] = false;
$smwgNamespacesWithSemanticLinks[NS_WIDGET_TALK] = false;
$smwgPageSpecialProperties = [
	'_MDAT',
	'_CDAT',
];

##### SemanticExtraSpecialProperties
wfLoadExtension( 'SemanticExtraSpecialProperties' );
$sespgEnabledPropertyList = [
	'_EUSER',
	'_CUSER',
	'_PAGEID',
];

##### SemanticResultFormats
wfLoadExtension( 'SemanticResultFormats' );

##### SyntaxHighlight_GeSHi
wfLoadExtension( 'SyntaxHighlight_GeSHi' );

##### TemplateData
wfLoadExtension( 'TemplateData' );

##### UrlGetParameters
require_once $IP . '/extensions/UrlGetParameters/UrlGetParameters.php';

##### UserFunctions
$wgUFAllowedNamespaces = array_fill( 0,
	4000,
	true );
$wgUFAllowedNamespaces += array_fill( 50000,
	5000,
	true );

##### Variables
wfLoadExtension( 'Variables' );

##### VisualEditor
wfLoadExtension( 'VisualEditor' );
$wgTmpDirectory = $IP . '/images/temp/';
$wgExtraSignatureNamespaces = [ NS_MAIN ];
$wgVisualEditorEnableWikitext = true;
$wgVisualEditorEnableDiffPage = true;
for ( $i = 50000; $i < 55000; $i += 2 ) {
	$wgContentNamespaces[] = $i;
}
$wgVisualEditorNamespaces = array_merge( $wgContentNamespaces,
	[ NS_USER ] );

##### Widgets
wfLoadExtension( 'Widgets' );

##### WikiSearch (and WikiSearchFront)
wfLoadExtension( 'WikiSearch' );
wfLoadExtension( 'WikiSearchFront' );

##### WSSemanticParsedText
wfLoadExtension( 'WSSemanticParsedText' );
$smwgElasticsearchConfig["indexer"]["raw.text"] = true;

##### WSSlots
wfLoadExtension( 'WSSlots' );
$wgWSSlotsDefaultSlotRoleLayout = [ "display" => "none",
	"region" => "center",
	"placement" => "append", ];
$wgWSSlotsDefaultContentModel = "wikitext";
$wgWSSlotsDefinedSlots = [ "ws-base-props", "ws-class-props" ];
$wgWSSlotsSemanticSlots = [ "ws-base-props", "ws-class-props" ];
$wgWSSlotsDoPurge = true;

##### WSSpaces
wfLoadExtension( 'WSSpaces' );
for ( $i = 50000; $i < 55000; $i++ ) {
	$smwgNamespacesWithSemanticLinks[$i] = true;
}

// Project namespace
$wgMetaNamespace = "Wiki";

// Short URL
// See https://www.mediawiki.org/wiki/Manual:Wiki_in_site_root_directory for a discussion about this setting.
$wgArticlePath = "/$1";
// See https://www.mediawiki.org/wiki/Manual:$wgUsePathInfo this may be a problem for some cgi setups
$wgUsePathInfo = true;

// Disable jobqueue on webrequest
$wgJobRunRate = 0;

/** Skin settings **/
wfLoadExtension( 'Bootstrap' );
wfLoadSkin( 'chameleon' );
$wgDefaultSkin = "chameleon";

// Define the location of the css and the layout xml
$egChameleonLayoutFile = "$IP/skin/wikibaseLayout.xml";
$egChameleonExternalStyleModules = glob( $IP . '/skin/scss/[^_]*.scss' );
$wgAllowSiteCSSOnRestrictedPages = true;

// Replace "Powered by SMW" by "Powered by Wikibase"
$wgFooterIcons = [ "copyright" => [ "copyright" => [], ],
	"poweredby" => [ "wikibase" => [ "src" => "/skin/PoweredByWikibase.png",
		"url" => "https://www.wikibase-solutions.com/",
		"alt" => "Powered by Wikibase", ], ], ];
$wgRightsIcon = null;

// Logo and favicon
$wgFavicon = "/skin/favicon.png";

// Common message files
$wgMessagesDirs['WikibaseSolutions'] = __DIR__ . '/../skin/i18n';

// Style settings
$egChameleonExternalStyleVariables = [ 'primary' => '#0576a8' ];
