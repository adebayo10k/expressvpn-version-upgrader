#!/bin/bash
# This module is responsible for creating a condition from which \
# a dev may decide whether or not to install an available package.
########################################################
function check_for_installed_public_key() {
	gpg --list-key | grep "release@expressvpn.com" >/dev/null 2>&1
	[ $? -ne 0 ] && \
	msg="IMPORTANT! The expressvpn Public Key MUST be installed. See https://www.expressvpn.com/support/vpn-setup/pgp-for-linux/" && \
	lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
}

# Try to get package information from apt-cache...
function get_currently_installed_pkg_version(){
    local user_selected_os_platform="$1"
	if [ $user_selected_os_platform = 'Ubuntu_64_bit' ] || [ $user_selected_os_platform = 'Raspberry_Pi_OS' ]
	then
		if ( which apt >/dev/null 2>&1 )
		then
			#echo "which apt returned true"
			apt_query=$(apt-cache show expressvpn 2>/dev/null)
		else
			echo "which apt returned false"
		fi

		if [ -n "$apt_query" ]
		then
			#echo "apt_query string was non-zero length"
			apt_pkg_version=$(echo $apt_query | sed 's/.*\(Version\)/\1/; s/\(Version:\ [0-9\.-]*\).*/\1/')
		else
			echo "apt_query string was NOT non-zero length"
		fi

		if [[ $apt_pkg_version =~ ^Version:[[:blank:]]+[0-9\.-]*$ ]]
		then
			echo -e "${BLUE}Currently Installed ${apt_pkg_version}${NC}" && echo
		else
			echo "apt_pkg_version did NOT match the regex"
		fi
	fi
}

# query the latest#linux webpage
function get_available_pkg_file_url() {
    local user_selected_os_platform="$1"
	# filter-in the latest package file URL from the expressvpn linux downloads landing page.
	case $user_selected_os_platform in
		'Ubuntu_64_bit') #Ubuntu 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_amd64.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
	    'Ubuntu_32_bit') #Ubuntu 32-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_i386.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
	    'Fedora_64_bit') #Fedora 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*.x86_64.rpm" | \
					sed 's/.*\(https\)/\1/; s/\(rpm\).*/\1/')
				;;
	    'Fedora_32_bit') #Fedora 32-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*.i386.rpm" | \
					sed 's/.*\(https\)/\1/; s/\(rpm\).*/\1/')
				;;
	    'Arch_64_bit') #Arch 64-bit
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn-[0-9\.-]*-x86_64.pkg.tar.xz" | \
					sed 's/.*\(https\)/\1/; s/\(xz\).*/\1/')
				;;
	    'Raspberry_Pi_OS') #Raspberry Pi OS
					pkg_file_url=$(curl -s "https://www.expressvpn.com/latest#linux" | \
					grep -m 1 "https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*_armhf.deb" | \
					sed 's/.*\(https\)/\1/; s/\(deb\).*/\1/')
				;;
		*)	   		msg="Unknown Linux Platform. Exiting now..."
	           		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
				;;
	esac

	# test the url string value from the https response:
	if [ -n $pkg_file_url ] && [[ $pkg_file_url =~ $BASIC_URL_REGEX/$REL_FILEPATH_REGEX ]]
	then
		echo -e "${BLUE}Available Version URL:"
		echo -e "$pkg_file_url${NC}" && echo
		# detatched signature file
		pkg_sig_file_url="${pkg_file_url}.asc"
		# get users' decision whether to progress from here
		question_string='Download and Verify this package? Choose an option'
		responses_string='Yes, Download and Verify|No, Quit the Program'
		get_user_response "$question_string" "$responses_string"
		user_response_code="$?"
		# affirmative case
		if [ "$user_response_code" -eq 1 ]; then
			echo && echo "Downloading and Verifying..." && echo
		else
			# negative case || unexpected case
			exit 0
		fi
	else
		msg="Could not download a VALID package file URL string from web. Exiting now..."
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi
} # end function

########################################################
# download package installation and package signature files
function download_pkg_file() {
    local pkg_file_url="$1"
    local pkg_sig_file_url="$2"
    local downloads_dir="$3"
	# test in a subshell, then cd 'for real' in program shell
	original_dir=$(pwd 2>/dev/null)
	if (cd "$downloads_dir" 2>/dev/null); then
		cd "$downloads_dir" 2>/dev/null
		#original_dir=$(cd - 2>/dev/null)
	else
		msg="Failed to change program directory to downloads_dir"
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

	curl -OL "$pkg_file_url" >/dev/stdout && \
	curl -sOL "$pkg_sig_file_url"
	if [ $? -ne 0 ]
	then
		msg="cURL Fail"
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi
} # end function

########################################################
# identify both package installation and package signature files
function identify_downloaded_pkg_file(){
    local pkg_file_url="$1"
    local pkg_sig_file_url="$2"
    local downloads_dir="$3"
    local pkg_file_regex="$4"
    local pkg_sig_file_regex="$5"
	# identified_pkg_file must match both the general pkg_file_regex and specific pkg_file_url just requested
	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_file_regex ]] && [[ ${file##*/} = ${pkg_file_url##*/} ]]
		then
			echo && echo -e "${BLUE}Found a Package Installation file: ${file}${NC}"
			identified_pkg_file="$file"
		fi
	done

	# identified_pkg_sig_file must match both the general pkg_sig_file_regex and specific pkg_sig_file_url just requested
	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_sig_file_regex ]] && [[ ${file##*/} = ${pkg_sig_file_url##*/} ]]
		then
			echo && echo -e "${BLUE}Found a Package Signature file: ${file}${NC}" && echo
			identified_pkg_sig_file="$file"
		fi
	done
} # end function

########################################################
# gpg verify signature of identified package file
function verify_downloaded_pkg_file(){
    local identified_pkg_file="$1"
    local identified_pkg_sig_file="$2"
	# Now to verify the downloaded package file using an existing expressvpn public key
	echo && echo -e "${GREEN}Now checking package file against expressvpn public key...${NC}" && echo
	gpg --fingerprint release@expressvpn.com
	gpg --verify "$identified_pkg_sig_file" "$identified_pkg_file"
	if [ $? -eq 0 ]
	then
		echo && echo -e "${GREEN}GPG VERIFICATION SUCCESSFUL.${NC} CONFIRM VISUALLY ANYWAY..." && echo
		# Get user permission to proceed...
		question_string='Confirm? Do you see "Good signature"? Choose an option'
		responses_string='Yes, Confirmed|No, Quit the Program'
		get_user_response "$question_string" "$responses_string"
		user_response_code="$?"
		# affirmative case
		if [ "$user_response_code" -eq 1 ]; then
			echo && echo "Continuing..." && echo
		else
			# negative case || unexpected case
			exit 0
		fi
	else
		msg="GPG SIGNATURE VERIFICATION FAILED!"
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

	verified_pkg_file="$identified_pkg_file"
} # end function

########################################################
