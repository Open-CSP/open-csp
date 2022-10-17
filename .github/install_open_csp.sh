#!/bin/sh

# if required, edit these to use different executables for php/git/composer.
COMPOSER=composer
PHP=php
GIT=git
CSP_BRANCH=main

main () {

    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    MW_PATH=$1
    OLD_PATH=$(pwd)

    validate_mw_path $MW_PATH || exit 1
    copy_files_from_git $MW_PATH

    echo "Moving to $MW_PATH"
    cd $MW_PATH

    echo "Setting up \"LocalSettings.php\""
    setup_localsettings

    do_composer

    run_maintenance_scripts

    echo "Moving to $OLD_PATH"
    cd $OLD_PATH

    succes_message
}

usage()
{
    echo "Usage: $0 <mediawiki path>";
    echo "Example: $0 \"/var/www/wiki/\""
}

validate_mw_path()
{
    if [ -d "$1" ]; then
        if [ -e "$1/composer.json" ]; then
            // Use php for checking the json.
            $PHP -r '$json = json_decode(file_get_contents("'$1/composer.json'"),true);if (!is_array($json)) {echo "composer file is not in valid json format\n";exit(1);} if (!isset($json["name"])) {echo "composer json does not have \"name\" parameter.\n";exit(1);} if($json["name"] !== "mediawiki/core") {echo "composer json \"name\" parameter is not equal to \"mediawiki/core\"\n";exit(1);}exit(0);'
            if [ $? -eq 0 ]; then
                return 0
            else
                echo "Not the mediawiki core composer json: $1/composer.json"
            fi
        else
            echo "No composer.json found in directory: $1"
        fi
    else
        echo "Not a directory: $MW_PATH"
    fi
    return 1
}

copy_files_from_git()
{
    echo "Cloning files from git."
    $GIT clone git@github.com:Open-CSP/open-csp.git --branch $CSP_BRANCH --single-branch || exit 1;
    echo "Copying files from git to $1."
    cp -r open-csp/[!.]* $1 || exit 1
    echo "removing git repository."
    rm -rf open-csp
}

setup_localsettings()
{
    # If LocalSettings.php does not include 'require_once(settings/CSPSettings.php)', add such a line.
    grep '^require_once(.\./settings/CSPSettings.php.);$' LocalSettings.php ||
        echo "\n#Settings for the OpenCSP framework\nrequire_once('./settings/CSPSettings.php');\n" >> LocalSettings.php

    #4. Use your favorite text editor to set `$wgSiteName` and `smwgElasticsearchEndpoints` in `./settings/CSPSettings.php` to the correct values.
    #TODO

    #TODO: test if settings actually work, esp. the elasticsearch connection.
}

do_composer()
{
    #5. Add the public WikibaseSolutions repository to your `composer.json` and run `composer update --no-dev` twice to install all required extensions and dependencies.
    $COMPOSER config repositories.38 composer https://gitlab.wikibase.nl/api/v4/group/38/-/packages/composer/ || exit 1
    $COMPOSER update --no-dev || exit 1
    $COMPOSER update --no-dev || exit 1
}

run_maintenance_scripts()
{
    #6. Run the following maintenance scripts:
    $PHP maintenance/update.php --quick || exit 1
    $PHP extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php || exit 1
    $PHP extensions/SemanticMediaWiki/maintenance/setupStore.php || exit 1
    $PHP extensions/SemanticMediaWiki/maintenance/rebuildElasticIndex.php || exit 1

    #7. Run the PageSync maintenance script.
    $PHP extensions/PageSync/maintenance/WSps.maintenance.php --user 'Maintenance script' || exit 1
}

succes_message()
{
    echo "\n\n\nInstallation of the CSP framework has been succesfully completed.\n"
    echo "Everything should work now! Visit your site to see if there are problems."
    echo "Consider replacing '$MW_PATH/logo/Logo.svg' with your own and/or editing the page 'Widget:Logo' on your wiki."
}

main "$@"
