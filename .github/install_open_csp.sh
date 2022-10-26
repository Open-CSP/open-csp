#!/bin/sh

# if required, edit these to use different executables for php/git/composer.
COMPOSER=composer
PHP=php
GIT=git

#The branch/ref from which we want to install the open csp framework
CSP_BRANCH=main

main ()
{

    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    CURRENT_STEP=0
    if [ $# -ge 2 ]; then
        SKIP_STEPS=$2
    else
        SKIP_STEPS=0
    fi

    MW_PATH=$1
    OLD_PATH=$(pwd)

    validate_mw_path $MW_PATH || exit 1

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Copying files from git"
        copy_files_from_git
    fi
    CURRENT_STEP=$(($CURRENT_STEP+1))

    echo "Moving to $MW_PATH"
    cd $MW_PATH || exit 1

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Setting up \"LocalSettings.php\""
        setup_localsettings
    fi
    CURRENT_STEP=$(($CURRENT_STEP+1))

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Running composer."
        do_composer
    fi
    CURRENT_STEP=$(($CURRENT_STEP+1))

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Running maintenance scripts"
        run_maintenance_scripts
    fi
    CURRENT_STEP=$(($CURRENT_STEP+1))

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Running PageSync scripts"
        run_pagesync_scripts
    fi
    CURRENT_STEP=$(($CURRENT_STEP+1))

    if [ $SKIP_STEPS -le $CURRENT_STEP ]; then
        echo ">>> Step $CURRENT_STEP: Running rebuildData"
        run_rebuild_data
    fi
    CURRENT_STEP=$((CURRENT_STEP+1))

    echo "Moving to $OLD_PATH"
    cd $OLD_PATH

    succes_message
}

usage()
{
    echo "Usage: $0 <mediawiki path> [<steps to skip>]";
    echo "Example: $0 \"/var/www/wiki/\""
    echo ""
    echo "<mediawiki path>:   The full path to your mediawiki installation"
    echo "<steps to skip>:    An integer that says how many steps to skip: 0 is full installation, 1 does all but the first step, etc."
}

exit_with_message()
{
    echo "\n\nThe installation was unsuccessfull."
    echo "Please read the error messages above, and act accordingly."
    echo ""
    echo "It could be that your problem is already mentioned on our Installation troubleshooting:"
    echo "https://github.com/Open-CSP/open-csp/blob/$CSP_BRANCH/.github/INSTALLATION_FAQ.md"
    echo ""
    echo "After resolving the issue, you can continue installation from the current step with the following command:"
    echo "$0 \"$MW_PATH\" $CURRENT_STEP"

    exit 1
}

validate_mw_path()
{
    if [ -d "$1" ]; then
        if [ -e "$1/composer.json" ]; then
            # Use php for checking the json.
            $PHP -r '$json = json_decode(file_get_contents("'$1'/composer.json"),true);if (!is_array($json)) {echo "composer file is not in valid json format\n";exit(1);} if (!isset($json["name"])) {echo "composer json does not have \"name\" parameter.\n";exit(1);} if($json["name"] !== "mediawiki/core") {echo "composer json \"name\" parameter is not equal to \"mediawiki/core\"\n";exit(1);}exit(0);'
            if [ $? -eq 0 ]; then
                if [ -e "$1/LocalSettings.php" ]; then
                    return 0
                else
                    echo "Could not find $1/LocalSettings.php. Please first set up your mediawiki installation."
                fi
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
    $GIT clone https://github.com/Open-CSP/open-csp.git --branch $CSP_BRANCH --single-branch || exit_with_message;
    echo "Copying files from git to $MW_PATH."

    cp -i open-csp/composer.local.json $MW_PATH
    cp -ri open-csp/settings $MW_PATH
    cp -ri open-csp/logo $MW_PATH
    cp -r open-csp/skin $MW_PATH || exit_with_message
    cp -r open-csp/wsps $MW_PATH || exit_with_message

    echo "removing git repository."
    rm -rf open-csp
}

setup_localsettings()
{
    # If LocalSettings.php does not include 'require_once(settings/CSPSettings.php)', add such a line.
    grep '^require_once(.\./settings/CSPSettings.php.);$' LocalSettings.php ||
        echo "\n#Settings for the Open CSP framework\nrequire_once('./settings/CSPSettings.php');\n" >> LocalSettings.php

    # Also create the `images/temp` folder if it does not exist yet.
    mkdir -p images/temp
    chmod a+rwx images/temp
}

do_composer()
{
    #5. Add the public WikibaseSolutions repository to your `composer.json` and run `composer update --no-dev` twice to install all required extensions and dependencies.
    $COMPOSER config repositories.38 composer https://gitlab.wikibase.nl/api/v4/group/38/-/packages/composer/ || exit_with_message
    $COMPOSER update --no-dev || exit_with_message
    $COMPOSER update --no-dev || exit_with_message
}

run_maintenance_scripts()
{
    #6. Run the following maintenance scripts:
    $PHP maintenance/update.php --quick || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/setupStore.php || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/rebuildElasticIndex.php || exit_with_message
}

run_pagesync_scripts()
{
    #TODO: Have share file not contain a datetime
    BOILERPLATE_URL="https://raw.githubusercontent.com/Open-CSP/PageSync-SharedFiles/main/Open-CSP/Installation/PageSync_21-10-2022-12-20-53_2-1-0.zip"

    #7. Run the PageSync maintenance script.
    $PHP extensions/PageSync/maintenance/WSps.maintenance.php --user 'Open CSP installation script' || exit_with_message

    #8. Install some extra pages to welcome the new users.
    echo "Installing the Open CSP main page."
    $PHP extensions/PageSync/maintenance/WSps.maintenance.php --silent --user 'Open CSP installation script' --install-shared-file $BOILERPLATE_URL || exit_with_message
}

run_rebuild_data()
{
    $PHP extensions/SemanticMediaWiki/maintenance/rebuildData.php || exit_with_message
}

succes_message()
{
    echo "\n\n\nInstallation of the CSP framework has been succesfully completed.\n"
    echo "Everything should work now! Visit your site to see if there are problems."
    echo "Consider replacing '$MW_PATH/logo/Logo.svg' with your own and/or editing the page 'Widget:Logo' on your wiki."
}

main "$@"
