#!/bin/bash
# This module is responsible for putting the host back into a state in which \
# it was found, regarding downloaded files, program and system configurations.
########################################################

# remove downloaded package file and restore original expressvpn preferences
function cleanup_and_revert(){

	if [ -f "$installed_pkg_file" ] && rm "$installed_pkg_file"
	then
		echo "Upgrade package file has been cleaned up after use OK" && echo && sleep 1
	else
		echo "Hmm, strange... the package file did NOT exist. Never mind."
	fi

	# revert any expressvpn preferences or configuration changes
	# TODO:revert using previously parsed output of preferences subcommand
	# cd back to original directory
	# clean up both/all package and signature files

} # end function

########################################################
#
function reconnect_expressvpn() {
	
	# TODO:if nmcli installed ...
	sudo systemctl restart NetworkManager.service
	#[ $? -eq 0 ] && \
	#expressvpn disconnect && expressvpn connect

	# nmcli networking connectivity check
	# nmcli device show
	# nmcli -t -f RUNNING general
	# 
	# report expressvpn status
	#sleep 4 && expressvpn status

} # end function

########################################################