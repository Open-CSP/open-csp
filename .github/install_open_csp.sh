#!/bin/bash

# if required, edit these to use different executables for php/git/composer.
COMPOSER=composer
PHP=php
GIT=git

# The branch/ref from which we want to install the open csp framework
CSP_BRANCH=main

# Invocation command
CMD="$@"

# In this file the last completed step will remain stored, at least until a reboot assuming /tmp is mounted as tmpfs.
TEMPFILE_PROGRESS=/tmp/install-open-csp.save

#####################################################################
# Don't change stuff below here unless you know what you're doing.
#####################################################################
trap 'echo -e "\nAborting installation..."; exit 1' SIGINT SIGTERM

TWIDTH=$(tput cols)
# Text style / colour variables
declare -A TSC
TSC[reset]=$(tput sgr0)		# Text reset
TSC[underline]=$(tput sgr 0 1)	# Underline
TSC[bold]=$(tput bold)		# Bold
TSC[green]=$(tput setaf 2)	# Green
TSC[red]=$(tput setaf 1)	# Red
TSC[yellow]=$(tput setaf 3)	# Yellow

declare -A INDEX STEPS MESSAGES PARAMS # Various steps make a walk
INDEX[copy_files_from_git]=0;           STEPS[0]="copy_files_from_git";           MESSAGES[0]="Copy files from git";                 PARAMS[copy-files]=0
INDEX[setup_localsettings]=1;           STEPS[1]="setup_localsettings";           MESSAGES[1]="Setting up LocalSettings.php";        PARAMS[setup-localsettings]=1
INDEX[do_composer]=2;                   STEPS[2]="do_composer";                   MESSAGES[2]="Running composer";                    PARAMS[composer]=2
INDEX[run_maintenance_scripts]=3;       STEPS[3]="run_maintenance_scripts";       MESSAGES[3]="Running maintenance scripts";         PARAMS[maintenance-scripts]=3
INDEX[run_pagesync_scripts]=4;          STEPS[4]="run_pagesync_scripts";          MESSAGES[4]="Running PageSync scripts";            PARAMS[pagesync]=4
INDEX[run_rebuild_data]=5;              STEPS[5]="run_rebuild_data";              MESSAGES[5]="Running rebuildData";                 PARAMS[rebuild-data]=5

function usage()
{ # help information
    cat <<EOF

    ${TSC[underline]}Usage${TSC[reset]}: $0 <mediawiki path> [optional arguments]
    ${TSC[underline]}Example${TSC[reset]}: $0 "/var/www/wiki/"
    
    <mediawiki path>        The full path to your MediaWiki installation.
    --skip-steps=X          X is an integer that says how many steps to skip: 0 is full installation, 1 does all but the first step, etc. This and --run are mutually exclusive.
    --manual (default)      Manual installation mode involves prompts to guide you through the installation process.
    --automatic             Automatic installation mode will install the framework without any prompts.
    --unattended            Same as automatic.
    --run=<step>            Run only the specified step. Only one step may be specified. This and --skip-steps are mutually exclusive.
                            Options are: copy-files, setup-localsettings, composer, maintenance-scripts, pagesync, rebuild-data
    --upgrade-mw            Upgrade your MediaWiki installation to meet the requirements for the Open CSP framework. This is a predefined set of installations steps which, when specified, will override --skip-steps and --run arguments.
    --install-open-csp      Install the Open CSP framework. This is a predefined set of installations steps which, when specified, will override --skip-steps and --run arguments. It assumes your MediaWiki installation is already up to snuff.
    --do-not-copy-wsps      Do not copy the wsps folder from the git repository. This is useful if you already have a wsps folder in your MediaWiki installation that you don't want overwritten.
    --help                  Show this help message.

EOF
    exit 1
}
if [ $# -lt 1 ] || [ ! -d "$1" ]; then usage; fi # No need to go any further if no path was even provided.

### Some prep stuff here
# Process arguments into variables
# Read MW_PATH from $1 and shift it off the argument list
MW_PATH=$1
shift
while [[ $# -gt 0 ]]; do
    case "$1" in
        --*=*) arg=${1/--/}; key=${arg%=*}; value=${arg#*=} ;; # Arguments with values
        --*) key=${1/--/}; key=${key//-/_}; value=1 ;; # Arguments without values
        *) shift; continue ;;
    esac
    eval "export $(echo ${key^^}|tr '-' '_')=$value" # Set parameter variable
    shift
done
if [ x$UNATTENDED == x1 ]; then
    AUTOMATIC=1
fi
if [ x$MANUAL != x1 ] && [ x$AUTOMATIC != x1 ]; then # If neither MANUAL or AUTOMATIC is set, default to MANUAL.
    MANUAL=1
fi
# Check if mutually exclusive arguments are used.
if [ ! -z "$SKIP_STEPS" ] && [ ! -z "$RUN" ]; then
    echo "${TSC[red]}Error${TSC[reset]}: --skip-steps and --run are mutually exclusive."
    usage
fi
if [ x$MANUAL == x1 ] && [ x$AUTOMATIC == x1 -o x$UNATTENDED == x1 ]; then
    echo "${TSC[red]}Error${TSC[reset]}: --manual and --automatic are mutually exclusive."
    usage
fi
if [ x$UPGRADE_MW == x1 ] && [ x$INSTALL_OPEN_CSP == x1 ]; then
    echo "${TSC[yellow]}Notice${TSC[reset]}: --upgrade-mw and --install-open-csp together are the same as omitted. Ignoring both..."
    unset UPGRADE_MW
    unset INSTALL_OPEN_CSP
fi
# Build the steps array
function remove_skips()
{
    if [ -n "$SKIP_STEPS" ]; then # Take away the steps to skip
        for ((i=0; i < SKIP_STEPS; i++)); do
            unset STEPS_TO_RUN[0]
            STEPS_TO_RUN=("${STEPS_TO_RUN[@]}")
        done
    elif [ -f $TEMPFILE_PROGRESS ]; then
        LAST_REACHED=$(cat $TEMPFILE_PROGRESS)
        while [ ${STEPS_TO_RUN[0]} -le $LAST_REACHED ]; do
            unset STEPS_TO_RUN[0]
            STEPS_TO_RUN=("${STEPS_TO_RUN[@]}")
        done
    fi
}
if [ x$UPGRADE_MW == x1 ]; then
    STEPS_TO_RUN=(${INDEX[copy_files_from_git]} ${INDEX[setup_localsettings]} ${INDEX[do_composer]} ${INDEX[run_maintenance_scripts]} ${INDEX[run_rebuild_data]})
elif [ x$INSTALL_OPEN_CSP == x1 ]; then
    STEPS_TO_RUN=(${INDEX[copy_files_from_git]} ${INDEX[run_pagesync_scripts]} ${INDEX[run_rebuild_data]})
else
    # If RUN is set, fetch the step number by matching the variable's value to the PARAMS array.
    if [ x$RUN != x ]; then
        STEPS_TO_RUN=${PARAMS[${RUN}]}
        if [ -z "$STEPS_TO_RUN" ]; then
            echo "${TSC[red]}Error${TSC[reset]}: Invalid run step specified."
            usage
        fi
    else
        if [[ x$SKIP_STEPS != x ]]; then
            if [[ ! $SKIP_STEPS =~ ^[0-9]+$ ]] || [ $SKIP_STEPS -lt 0 ] || [ $SKIP_STEPS -gt 5 ]; then
                echo "${TSC[red]}Error${TSC[reset]}: Invalid --skip-steps value specified."
                usage
            fi
        fi
        STEPS_TO_RUN=(${INDEX[copy_files_from_git]} ${INDEX[setup_localsettings]} ${INDEX[do_composer]} ${INDEX[run_maintenance_scripts]} ${INDEX[run_pagesync_scripts]} ${INDEX[run_rebuild_data]})
        remove_skips
    fi
fi
# If either UPGRADE_MW or INSTALL_OPEN_CSP is set, also apply the removal of SKIP_STEPS but only if that means we'll have any left.
if [ x$UPGRADE_MW == x1 -o x$INSTALL_OPEN_CSP == x1 ]; then
    STEPS_BACKUP=("${STEPS_TO_RUN[@]}")
    remove_skips
    if [ ${#STEPS_TO_RUN[@]} -eq 0 ]; then
        STEPS_TO_RUN=("${STEPS_BACKUP[@]}")
    fi
fi
# If DO_NOT_COPY_WSPS is set but step run_pagesycopy_files_from_git is not in the steps to run, inform the user it will be ignored.
if [ x$DO_NOT_COPY_WSPS == x1 ] && [[ ! " ${STEPS_TO_RUN[@]} " =~ " ${INDEX[copy_files_from_git]} " ]]; then
    echo "${TSC[yellow]}Notice${TSC[reset]}: --do-not-copy-wsps is ignored because the copy_files_from_git step is not included."
fi
# If AUTOMATIC is not set, provide a prompt to confirm the steps to run.
if [ x$MANUAL == x1 ]; then
    echo "The following steps will be run:"
    for step in "${STEPS_TO_RUN[@]}"; do
        echo -e "\t${TSC[bold]}- ${MESSAGES[$step]}${TSC[reset]}"
    done
    read -p "Do you wish to continue? [Y/n] " -n 1 input
    if [[ $input =~ ^[Nn]$ ]]; then
        echo -e "\nAborting installation."
        exit 1
    fi
fi

function main ()
{
    validate_mw_path $MW_PATH || exit 1
    echo "Moving to $MW_PATH"
    cd $MW_PATH || exit 1

    for step in "${STEPS_TO_RUN[@]}"; do
        if [ x$AUTOMATIC == x ]; then # Prompt user if not in auto mode
            read -p "Next step: '${MESSAGES[$step]}' Continue? [Y/n] " -n 1 input
            if [[ $input =~ ^[Nn]$ ]]; then
                echo -e "\nAborting installation."
                exit 1
            fi
        fi
        echo -e "\n${TSC[bold]}${TSC[green]}${MESSAGES[$step]} ...${TSC[reset]}"
        ${STEPS[$step]} || exit_with_message # Do the thing
        # If $step is nonzero, write it to the tempfile.
        if [ $step -gt 0 ]; then
            echo -n $step > $TEMPFILE_PROGRESS
        fi
    done

    succes_message
}

function exit_with_message()
{
    echo -e "\n\nThe installation was unsuccessfull."
    echo "Please read the error messages above, and act accordingly."
    echo ""
    echo "It could be that your problem is already mentioned on our Installation troubleshooting:"
    echo "https://github.com/Open-CSP/open-csp/blob/$CSP_BRANCH/.github/INSTALLATION_FAQ.md"
    echo ""
    echo "After resolving the issue, you may resume using the following command:"
    echo "$CMD"

    exit 1
}

function validate_mw_path()
{
    return 0
    if [ -d "$1" ]; then
        if [ -e "$1/composer.json" ]; then
            # Use php for checking the json.
            $PHP -r '$json = json_decode(file_get_contents("'$1'/composer.json"),true);if (!is_array($json)) {echo "composer file is not in valid json format\n";exit(1);} if (!isset($json["name"])) {echo "composer json does not have \"name\" parameter.\n";exit(1);} if($json["name"] !== "mediawiki/core") {echo "composer json \"name\" parameter is not equal to \"mediawiki/core\"\n";exit(1);}exit(0);'
            if [ $? -eq 0 ]; then
                if [ -e "$1/LocalSettings.php" ]; then
                    return 0
                else
                    local altpath=$(find $1/ -mindepth=1 -maxdepth=4 -type f -name "LocalSettings.php" -exec dirname {} \; -quit 2>/dev/null)
                    if [ x$altpath == x ]; then
                        echo "Could not find $1/LocalSettings.php. Please first set up your mediawiki installation."
                    else
                        local input
                        read -p "Could not find $1/LocalSettings.php. Did you mean to point at '$altpath' instead? [y/N] " -n 1 input
                        if [[ $input =~ ^[Yy]$ ]]; then
                            MW_PATH=$altpath
                            return 0
                        else
                            echo "Invalid path provided."
                        fi
                    fi
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

function copy_files_from_git()
{
    if [ x$AUTOMATIC == x1 ]; then
        rm -rf open-csp 2>/dev/null # Remove any leftovers from previous runs to prevent... problem... stuff
    else
        local $prompt="-i"
    fi

    echo "Cloning files from git."
    $GIT clone https://github.com/Open-CSP/open-csp.git --branch $CSP_BRANCH --single-branch || exit_with_message;
    echo "Copying files from git to $MW_PATH."

    cp $prompt open-csp/composer.local.json $MW_PATH
    cp $prompt -r open-csp/settings $MW_PATH
    cp $prompt -r open-csp/logo $MW_PATH
    cp -r open-csp/skin $MW_PATH || exit_with_message

    if [ x$DO_NOT_COPY_WSPS == x1 ]; then
        echo "Skipping copying wsps folder."
    else
        if [ x$AUTOMATIC == x1 ]; then
            cp -r open-csp/wsps $MW_PATH || exit_with_message
        else
            read -p "Copy the wsps folder from the git repository? [Y/n] " -n 1 input
            if [[ $input =~ ^[Nn]$ ]]; then
                echo "Skipping copying wsps folder."
            else
                cp -r open-csp/wsps $MW_PATH || exit_with_message
            fi
        fi
    fi    

    echo "removing git repository."
    rm -rf open-csp
}

function setup_localsettings()
{
    # If LocalSettings.php does not include 'require_once(settings/CSPSettings.php)', add such a line.
    grep '^require_once(.\./settings/CSPSettings.php.);$' LocalSettings.php ||
        printf "\n#Settings for the Open CSP framework\nrequire_once('./settings/CSPSettings.php');\n" >> LocalSettings.php

    # Also create the `images/temp` folder if it does not exist yet.
    mkdir -p images/temp
    chmod a+rwx images/temp
}

function do_composer()
{
    #5. Add the public WikibaseSolutions repository to your `composer.json` and run `composer update --no-dev` twice to install all required extensions and dependencies.
    $COMPOSER config repositories.38 composer https://gitlab.wikibase.nl/api/v4/group/38/-/packages/composer/ || exit_with_message
    $COMPOSER update --no-dev || exit_with_message
    $COMPOSER update --no-dev || exit_with_message
}

function run_maintenance_scripts()
{
    #6. Run the following maintenance scripts:
    $PHP maintenance/update.php --quick || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/updateEntityCountMap.php || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/setupStore.php || exit_with_message
    $PHP extensions/SemanticMediaWiki/maintenance/rebuildElasticIndex.php || exit_with_message
}

function run_pagesync_scripts()
{
    #TODO: Have share file not contain a datetime
    BOILERPLATE_URL="https://raw.githubusercontent.com/Open-CSP/PageSync-SharedFiles/main/Open-CSP/Installation/PageSync_21-10-2022-12-20-53_2-1-0.zip"

    #7. Run the PageSync maintenance script.
    $PHP extensions/PageSync/maintenance/WSps.maintenance.php --user 'Open CSP installation script' || exit_with_message
}

function run_rebuild_data()
{
    $PHP extensions/SemanticMediaWiki/maintenance/rebuildData.php || exit_with_message
}

function succes_message()
{
    rm -f $TEMPFILE_PROGRESS 2>/dev/null # Ditch our progress
    echo -e "${TSC[green]}${TSC[bold]}\nAll selected installation steps have succesfully completed.${TSC[reset]}\n"
    echo "Consider replacing '$MW_PATH/logo/Logo.svg' with your own and/or editing the page 'Widget:Logo' on your wiki."
}

main
