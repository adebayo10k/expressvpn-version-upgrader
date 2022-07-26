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
	case $detected_plat in
		'U64') #Ubuntu 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_amd64.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
	    'U32') #Ubuntu 32-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_i386.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
	    'F64') #Fedora 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*.x86_64.rpm" | \
					sed 's/.*\(https\)/\1/; s/\(rpm\).*/\1/')
				;;
	    'F32') #Fedora 32-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*.i386.rpm" | \
					sed 's/.*\(https\)/\1/; s/\(rpm\).*/\1/')
				;;
	    'A64') #Arch 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*-x86_64.pkg.tar.xz" | \
					sed 's/.*\(https\)/\1/; s/\(xz\).*/\1/')
				;;
	    'RPi') #Raspberry Pi OS
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_armhf.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
		*)	   		msg="Unknown Linux Platform. Exiting now..."
	           		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
				;;
	esac

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

	msg="Want to download and verify the package and signature files?.."
	lib10k_get_user_permission_to_proceed "$msg"
	[ $? -eq 0 ] || exit 0

} # end function

########################################################
# 
function download_pkg_file() {
	# detatched signature file
	pkg_sig_file_url="${pkg_file_url}.asc"
	cd "$downloads_dir" && \
	curl -OL "$pkg_file_url" >/dev/stdout && \
	curl -sOL "$pkg_sig_file_url"
	if [ $? -ne 0 ]
	then
		msg="cURL FAIL"
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

} # end function

########################################################
# 
function identify_downloaded_pkg_file(){

	local pkg_file_regex="^${downloads_dir}/expressvpn[-_]{1}[0-9\.-]*.*(deb|rpm|xz)$"
	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_file_regex ]]
		then
			echo && echo "Found an expressvpn package file: ${file}" && echo
			identified_pkg_file="$file"
		fi
	done

} # end function

########################################################

# gpg verify signature of identified package file
function verify_downloaded_pkg_file(){	

	# Now to verify the downloaded package file using an existing expressvpn public key
	echo && echo -e "\e[32mNow checking package file against expressvpn public key...\e[0m" && echo
	gpg --fingerprint release@expressvpn.com
	gpg --verify "${identified_pkg_file}.asc" "$identified_pkg_file"
	if [ $? -eq 0 ]
	then
		echo && echo "GPG VERIFICATION PASSED OK, BUT AUTHORISE MANUALLY ANYWAY..."
	else
		msg="GPG SIGNATURE VERIFICATION FAILED!"
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

	# Get user permission to proceed...
	msg="\e[33mPress ENTER to confirm a \"Good signature\"\e[0m"
	lib10k_get_user_permission_to_proceed "$msg"
	[ $? -eq 0 ] || exit 0;

	verified_pkg_file="$identified_pkg_file"

} # end function

########################################################
