#!/bin/bash
# This module is responsible for completing a package installation.
function install_package(){
    local verified_pkg_file="$1"
	# Get user permission to proceed...
	question_string='Proceed with Package Installation? (requires sudo). Choose and option'
	responses_string='Yes, Install|No, Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# affirmative case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "Installing..." && echo
	else
		# negative case || unexpected case
		exit 0
	fi
	
	sudo dpkg -i $verified_pkg_file
	return_code=$?;
	if [ $return_code -eq 0 ]
	then
		echo && echo -e "${GREEN}THE UPGRADE WAS SUCCESSFUL.${NC}" && echo
	else
		msg="The install (dpkg -i) command FAILED. Exiting now..."
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

    installed_pkg_file=$verified_pkg_file	
} # end function

