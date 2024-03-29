#!/bin/bash
#: Title				:expressvpn-version-upgrader.sh
#: Date					:2021-01-26
#: Author				: "Damola Adebayo" <adebayo10k@domain.com>
#: Description	:use to safely update this frequently upgraded, 
#: Description	:not apt- or snap- package managed program 

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

### Library functions have now been read-in ###

# verify existence of included dependencies
if [ -d "${command_dirname}/includes" ] && \
[ -n "$(ls ${command_dirname}/includes)" ]
then
	for file in "${command_dirname}/includes"/*
	do
		source "$file"
	done
else
	msg="Required file not found. Returning non-zero exit code. Exiting now..."
	lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
fi

### Included file functions have now been read-in ###

# CALLS TO FUNCTIONS DECLARED IN helper.inc.sh
#==========================
check_all_program_preconditions

function main(){
	#########################
	# GLOBAL VARIABLE DECLARATIONS:
	#########################		
	pkg_file_url=
    pkg_sig_file_url=
	identified_pkg_file=
    identified_pkg_sig_file=
	verified_pkg_file=
    original_dir=

	#########################
	# FUNCTION CALLS:
	#########################	

	# CALLS TO FUNCTIONS DECLARED IN setup.inc.sh
	#==========================
	# no point going further if this state ...
	check_for_installed_public_key

	# CALLS TO FUNCTIONS DECLARED IN controller.inc.sh
	#==========================
	# user manually selects which ...
	get_user_platform_choice "${os_platforms[@]}"

	# CALLS TO FUNCTIONS DECLARED IN setup.inc.sh
	#==========================
	# retreive the url string for the latest package and compare with existing version.
	get_currently_installed_pkg_version	"$user_selected_os_platform"
	#test_call_get_user_continue_response
	get_available_pkg_file_url	"$user_selected_os_platform"
	## cURL the package file to the Downloads directory.
	download_pkg_file "$pkg_file_url" "$pkg_sig_file_url" "$downloads_dir"
	# identify both package and package signature files
	identify_downloaded_pkg_file "$pkg_file_url" "$pkg_sig_file_url" "$downloads_dir" "$pkg_file_regex" "$pkg_sig_file_regex"
	## then to verify its' signature against the expressvpn public key
	verify_downloaded_pkg_file "$identified_pkg_file" "$identified_pkg_sig_file"
#
	## CALLS TO FUNCTIONS DECLARED IN pkg-installation.inc.sh
	##==========================
	#do the installation
 	install_package "$verified_pkg_file"
#
	## CALLS TO FUNCTIONS DECLARED IN cleanup.inc.sh
	##==========================
	# remove the downloaded files after installation
	cleanup_and_revert "$original_dir" "$downloads_dir" "$pkg_file_regex" "$pkg_sig_file_regex"
	# try to restart the network by brute
	reconnect_expressvpn

} # end main

main "$@"; exit $?
