#!/bin/bash
# This module is responsible for completing a package installation.
function install_package(){
	# Get user permission to proceed...
	question_string='Proceed with Package Installation? (requires sudo). Enter Number'
	responses_string='Yes(Install) No(Quit)'
	get_user_binary_exclusive_response "$question_string" "$responses_string"
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
		echo && echo -e "\e[32mTHE UPGRADE WAS SUCCESSFUL.\e[0m" && echo
	else
		msg="The install (dpkg -i) command FAILED. Exiting now..."
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

    installed_pkg_file=$verified_pkg_file	
} # end function

