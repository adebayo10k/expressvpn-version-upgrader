#!/bin/bash
# This module is responsible for creating a condition from which \
# a subsequent package installation can take place.
########################################################
#
function display_installed_version() {

	echo && echo "Installed version:"
	expressvpn -v 2>/dev/null
	[ $? -ne 0 ] &&  \
	msg="Problem: Cannot establish the version of your existing expressvpn package." && \
	lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	
} # end function

########################################################
# scrape the latest#linux webpage
function get_available_pkg_file_url() {

	# filter-in the latest package file URL from the expressvpn linux downloads landing page.
	pkg_file_url=$(curl -sL "$linux_pkg_dl_landing_page"  2>&1 | \
	grep "$pkg_file_url_regex" | \
	sed 's/^.*href="//' | \
	sed 's/".*//')

	# test the retrieved url value:
	if [ -n $pkg_file_url ] && [[ $pkg_file_url =~ $BASIC_URL_REGEX/$REL_FILEPATH_REGEX ]]
	then
		echo "Available version URL:"
		echo "$pkg_file_url" && echo
	else
		msg="Could not retrieve a valid package file URL. Exiting now..."
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

} # end function

########################################################
#
function get_user_pkg_download_decision() {

	msg="Want to download it? If not just terminate this program..."
	lib10k_get_user_permission_to_proceed "$msg"
	[ $? -eq 0 ] || exit 0

} # end function

########################################################
# 
function download_pkg_file() {

	cd ~/Downloads && \
	curl -OL $pkg_file_url >/dev/stdout
	if [ $? -ne 0 ]
	then
		msg=""
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi
	
} # end function

########################################################

# check there's ONLY 1 package file,
function identify_downloaded_pkg_file(){
    local pkg_file_regex="^${downloads_dir}/(expressvpn_).*${pkg_arch_regex}${pkg_fn_ext_regex}$"
    local declare -a downloaded_pkg_files=()
	for file in "${downloads_dir}"/*
	do
		if [ -f  "${file}" ] && [[ $file =~ $pkg_file_regex ]]
		then
			echo "Found an expressvpn package file: ${file}" && echo
			# add file to an array
			downloaded_pkg_files+=("${file}")
		fi
	done

	# report to user whether or not the expected, single upgrade file was found OK
	if [[ ${#downloaded_pkg_files[@]} -lt 1 ]]
	then
		msg="The package file has NOT been found. Exiting now..."
		lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
	elif [[ ${#downloaded_pkg_files[@]} -gt 1 ]]
	then
		msg="TOO MANY valid package files were found. MANUALLY DELETE redundant files. Exiting now..."
		lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
	else
		echo "${#downloaded_pkg_files[@]} package file was identified" && echo
	fi
	
	identified_pkg_file=${downloaded_pkg_files[0]}	

} # end function

########################################################

# gpg verify signature of identified package file
function verify_downloaded_pkg_file(){	

	# Now to verify the downloaded package file using an existing expressvpn public key
	echo && echo -e "\e[32mNOW CHECKING package file AGAINST EXPRESSVPN PUBLIC KEY\e[0m" && echo
	gpg --fingerprint release@expressvpn.com
	gpg --verify "$identified_pkg_file"

	# TODO: identify downloaded detatched signature
	# ... using detached signature....
	# gpg --verify "signature.asc" "$identified_pkg_file"
	# [ $? -eq 0 ] ...

	echo

	# Get user permission to proceed...
	msg="\e[33mPress ENTER to confirm a Good signature\e[0m"
	lib10k_get_user_permission_to_proceed "$msg"
	[ $? -eq 0 ] || exit 0;

	verified_pkg_file="$identified_pkg_file"

} # end function

########################################################
