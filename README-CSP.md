# The OpenCSP framework

The perfect Mediawiki framework for corporate use.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)

## Requirements

To install the OpenCSP framework, the following need to be installed:
- php version >=7.4
- composer version >=2
- Mediawiki version 1.35
- ElasticSearch version 6.8

## Installation

Follow these steps to set up your OpenCSP wiki:

0. [Install Mediawiki](https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki) version 1.35 and make sure you can connect to an ElasticSearch instance.
1. Clone this repository
```sh
git clone https://github.com/WikibaseSolutions/open-csp.git --branch main --single-branch
```
2. Copy the files to your Mediawiki installation and remove the clone. (Note: This might overwrite any pre-existing `composer.local.json`).
```sh
cp open-csp/* /path/to/your/mediawiki/core/
rm -r open-csp
```
3. Go to your mediawiki installation and add the line `require_once('./settings/CSPSettings.php');` to your `LocalSettings.php`.
```sh
cd /path/to/your/mediawiki/core/
echo -e "\n\n#Settings for the OpenCSP framework\nrequire_once('./settings/CSPSettings.php');\n" >> LocalSettings.php
```
4. Use your favorite text editor to set `$wgSiteName` and `smwgElasticsearchEndpoints` in `./settings/CSPSettings.php` to the correct values.
5. Add the public WikibaseSolutions repository to your `composer.json` and run `composer update --no-dev` twice to install all required extensions and dependencies.
```sh
composer config repositories.38 composer https://gitlab.wikibase.nl/api/v4/group/38/-/packages/composer/
composer update --no-dev
composer update --no-dev
```
6. Run the following maintenance scripts:
```sh
php maintenance/update.php --quick
php extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php
php extensions/SemanticMediaWiki/maintenance/setupStore.php
php extensions/SemanticMediaWiki/maintenance/rebuildElasticIndex.php
```
7. Use [PageSync]() to install the pages for a basic CSP wiki.
    - You can go to `https://your.wiki.example.com/Special:WSps?action=share` and upload the zip found in this repository.
    - You can do this using the terminal (if you have copied the complete `wsps`-directory in step 2) with the following command:
```sh
  php extensions/PageSync/maintenance/WSps.maintenance.php --user 'Maintenance script'
```
8. Everything should work now! Visit your site to see if there are problems.

## Usage

If installation went succesful, the wiki should show some pages with basic usage instructions. More information can be found on [our website](https://open-csp.org).

## Support

Please [open an issue](https://github.com/WikibaseSolutions/open-csp/issues/new) for support.
If you want more support, [contact us](https://wikibase-solutions.com/contact) for possibilities of continuous support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/WikibaseSolutions/open-csp/compare/).
