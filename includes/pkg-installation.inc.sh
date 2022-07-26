#!/bin/bash
# This module is responsible for completing a package installation.
########################################################
# do the actual installation and then to verify it.
function install_package(){

	msg="Press ENTER to proceed with upgrade installation..."
	lib10k_get_user_permission_to_proceed "$msg"
	[ $? -eq 0 ] || exit 0;

	# TODO: temporarily change expressvpn preferences?

	sudo dpkg -i $verified_pkg_file
	return_code=$?;
	if [ $return_code -eq 0 ]
	then
		echo "THE UPGRADE WAS SUCCESSFUL." && echo
	else
		msg="The install (dpkg -i) command FAILED. Exiting now..."
		lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
	fi

    installed_pkg_file=$verified_pkg_file
	
} # end function

