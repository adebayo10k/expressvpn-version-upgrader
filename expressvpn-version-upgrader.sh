#!/bin/bash
#: Title				:expressvpn-version-upgrader.sh
#: Date					:2021-01-26
#: Author				: "Damola Adebayo" <adebayo10k@domain.com>
#: Description	:use to securely update this frequently upgraded, 
#: Description	:not apt- or snap- package managed program 

## THIS STUFF NEEDS TO EXECUTE BEFORE MAIN FUNCTION CALL:

command_fullpath="$(readlink -f $0)" 
command_basename="$(basename $command_fullpath)"
command_dirname="$(dirname $command_fullpath)"

# verify existence of library dependencies
if [ -d "${command_dirname}/shared-functions-library" ] && \
[ -n "$(ls ${command_dirname}/shared-functions-library | grep  'shared-bash-')" ]
then
	for file in "${command_dirname}/shared-functions-library"/shared-bash-*
	do
		source "$file"
	done
else
	# return a non-zero exit code with native exit
	echo "Required file not found. Returning non-zero exit code. Exiting now..."
	exit 1
fi

# verify existence of included dependencies
if [ -d "${command_dirname}/includes" ] && \
[ -n "$(ls ${command_dirname}/includes)" ]
then
	for file in "${command_dirname}/includes"/*
	do
		source "$file"
	done
else
	# return a non-zero exit code with native exit
	echo "Required file not found. Returning non-zero exit code. Exiting now..."
	exit 1
fi

## THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!

function main(){
	#########################
	# GLOBAL VARIABLE DECLARATIONS:
	#########################
	program_title="expressvpn version upgrader"
	original_author="damola adebayo"
	program_dependencies=("expressvpn" "gpg" "dpkg" "curl" "nmcli")

	declare -i max_expected_no_of_program_parameters=0
	declare -i min_expected_no_of_program_parameters=0
	declare -ir actual_no_of_program_parameters=$#
	all_the_parameters_string="$@"
	
	declare -a authorised_host_list=()
	actual_host=`hostname`
	downloads_dir="$HOME/Downloads"

	pkg_file_url=
	identified_pkg_file=
	verified_pkg_file=
	declare -a downloaded_pkg_files=()
	pkg_file_regex="^${downloads_dir}/(expressvpn_).*${pkg_arch_regex}${pkg_filename_ext_regex}$"
	#installer_regex="^${downloads_dir}/(expressvpn_).*(\.deb)$"

	#########################
	# FUNCTION CALLS:
	#########################
	if [ ! $USER = 'root' ]
	then
		## Display a program header
		lib10k_display_program_header "$program_title" "$original_author"
		## check program dependencies and requirements
		lib10k_check_program_requirements "${program_dependencies[@]}"
	fi
	
	# check the number of parameters to this program
	lib10k_check_no_of_program_args
	# controls where this program can be run, to avoid unforseen behaviour
	lib10k_entry_test

	# CALLS TO FUNCTIONS DECLARED IN setup.inc.sh
	#==========================
	# display the currently installed version of expressvpn
	display_installed_version
	# retreive the url string for the latest package and compare with existing version.
	get_available_pkg_file_url
	# user manually decides whether to continue with or abandon package installation.
	get_user_pkg_download_decision
	# cURL the package file to the Downloads directory.
	download_pkg_file
	# check whether there's exactly 1 package file available
	identify_downloaded_pkg_file
	# then to verify its' signature against the expressvpn public key
	verify_downloaded_pkg_file

	# CALLS TO FUNCTIONS DECLARED IN pkg-installation.inc.sh
	#==========================
	# do, then verify the installation
 	install_package

	# CALLS TO FUNCTIONS DECLARED IN cleanup.inc.sh
	#==========================
	# remove the downloaded file after installation
	cleanup_and_revert
	# try to restart expressvpn
	reconnect_expressvpn


} # end main

main "$@"; exit $?