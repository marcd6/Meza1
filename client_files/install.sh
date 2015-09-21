#!/bin/bash
#
# Setup the entire Meza1 platform

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/Meza1#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

echo -e "\nWelcome to Meza1 v0.2.1\n"


#
# Set architecture to 32 or 64 (bit)
#
if [ $(uname -m | grep -c 64) -eq 1 ]; then
architecture=64
else
architecture=32
fi


# Prompt user for GitHub API personal access token
default_usergithubtoken="e9191bc6d394d64011273d19f4c6be47eb10e25b" # From Oscar Rogers
echo -e "\nIf you run this script multiple times from one IP address,"
echo -e "you might exceed GitHub's API rate limit."
echo -e "\nYou may just press [ENTER] to use our generic token (which may exceed limits if used too much) or"
echo -e "Visit https://github.com/settings/tokens to generate a new token (with no scopes)."
echo -e "and copy/paste your 40-character token and press [ENTER]: "
read usergithubtoken
usergithubtoken=${usergithubtoken:-$default_usergithubtoken}

# Prompt user for PHP version
while [ -z "$phpversion" ]
do
echo -e "\nVisit http://php.net/downloads.php for version numbers"
echo -e "Enter version of PHP you would like (such as 5.4.42) and press [ENTER]: "
read phpversion
done

while [ -z "$mysql_root_pass" ]
do
echo -e "\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done

while [ -z "$git_branch" ]
do
echo -e "\nEnter git branch of Meza1 you want to use (generally this is \"master\") [ENTER]: "
read git_branch
done

while [ "$mw_api_protocol" != "http" ] && [ "$mw_api_protocol" != "https" ]
do
echo -e "\nType http or https for MW API and press [ENTER]: "
read mw_api_protocol
done

while [ -z "$mw_api_domain" ]
do
echo -e "\nType domain or IP address of your wiki and press [ENTER]: "
read mw_api_domain
done

while [ -z "$mediawiki_git_install" ]
do
echo -e "\nInstall MediaWiki with git? (y/n) [ENTER]: "
read mediawiki_git_install
done


# Check if git installed, and install it if required
if ! hash git 2>/dev/null; then
    echo "************ git not installed, installing ************"
    yum install git -y
fi

# if no sources directory, create it
if [ ! -d ~/sources ]; then
	mkdir ~/sources
fi


#
# Output command to screen and to log files
#
timestamp=$(date "+%Y%m%d%H%M%S")
logpath="/root/sources/meza1/logs"
outlog="$logpath/${timestamp}_out.log"
errlog="$logpath/${timestamp}_err.log"
cmdlog="$logpath/${timestamp}_cmd.log"

# writes a timestamp with a message for profiling purposes
# Generally use in the form:
# Thu Aug  6 10:44:07 CDT 2015: START some description of action
cmd_profile()
{
	echo "`date`: $*" >> "$cmdlog"
}

# Use tee to send a command output to the terminal, but send stdout
# to a log file and stderr to a different log file. Use like:
# command_to_screen_and_logs "bash yums.sh"
cmd_tee()
{
	cmd_profile "START $*"
	$@ > >(tee -a "$outlog") 2> >(tee -a "$errlog" >&2)
	sleep 1 # why is this needed? It is needed, but why?
	cmd_profile "END $*"
}

# function to install Meza1 via git
install_via_git()
{
	cd ~/sources
	git clone https://github.com/enterprisemediawiki/Meza1 meza1
	cd meza1
	git checkout "$git_branch"
}

# Creates generic title for the beginning of scripts
print_title()
{
cat << EOM

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                             *
*  $*
*                                                             *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

EOM
}


# no meza1 directory
if [ ! -d ~/sources/meza1 ]; then
	install_via_git

# meza1 exists, but is not a git repo (hold over from older versions of meza1)
elif [ ! -d ~/sources/meza1/.git ]; then
	rm -rf ~/sources/meza1
	install_via_git

# meza1 exists and is a git repo: checkout latest branch
else
	cd ~/sources/meza1
	git fetch origin
	git checkout "$git_branch"
fi


# Load config constants. Unfortunately right now have to write out full path to
# Meza1 since we can't be certain of consistent method of accessing install.sh.
source /root/sources/meza1/client_files/config.sh


# @todo: Need to test for yums.sh functionality prior to proceeding
#    with apache.sh, and Apache functionality prior to proceeding
#    with php.sh, and so forth.
cd "$m_meza/client_files"
cmd_tee "source yums.sh"

cd "$m_meza/client_files"
cmd_tee "source install-imagick.sh"

cd "$m_meza/client_files"
cmd_tee "source apache.sh"

cd "$m_meza/client_files"
cmd_tee "source php.sh"

cd "$m_meza/client_files"
cmd_tee "source mysql.sh"

cd "$m_meza/client_files"
cmd_tee "source VE.sh"

cd "$m_meza/client_files"
cmd_tee "source ElasticSearch.sh"

cd "$m_meza/client_files"
cmd_tee "source mediawiki.sh"

cd "$m_meza/client_files"
cmd_tee "source extensions.sh"

# Remove GitHub API personal access token from .composer dir
# @todo: change the following to instead just remove the token from the file
#        in case there are other authentication entries
rm -f ~/.composer/auth.json


# Display Most Plusquamperfekt Wiki Pigeon of Victory
cat "$m_meza/client_files/pigeon.txt"

