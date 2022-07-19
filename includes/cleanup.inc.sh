#!/bin/bash

########################################################

# remove downloaded package file and restore original expressvpn preferences
function cleanup_and_revert(){

	if [ -f "$verified_pkg_file" ] && rm "$verified_pkg_file"
	then
		echo "Upgrade package file has been cleaned up after use OK" && echo && sleep 1
	else
		echo "Hmm, strange... the package file did NOT exist. Never mind."
	fi

	# revert any expressvpn preferences or configuration changes
	# cd back to original directory

} # end function

########################################################
#
function reconnect_expressvpn() {
	
	# if nmcli installed ...
	sudo systemctl restart NetworkManager.service
	#[ $? -eq 0 ] && \
	#expressvpn disconnect && expressvpn connect

	# nmcli networking connectivity check
	# nmcli device show
	# nmcli -t -f RUNNING general
	# 
	# report expressvpn status
	expressvpn status

} # end function

########################################################