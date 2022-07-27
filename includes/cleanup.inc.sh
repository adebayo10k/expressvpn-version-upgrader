#!/bin/bash
# This module is responsible for putting the host back into a state in which \
# it was found, regarding downloaded files, program and system configurations.
########################################################

# remove downloaded package and signature files, and restore original expressvpn preferences
function cleanup_and_revert() {

	while :
	do
		msg0="Remove the old Package and Signature file downloads? (recommended)"
		msg1="Enter [Y/n]"
		lib10k_get_user_response "$msg0" "$msg1"
		user_response_code="$?"
		[ "$user_response_code" -eq 2 ] && remove_pkg_files && break # yes; break while
		[ "$user_response_code" -eq 3 ] &&  break # no; break while
	done



} # end function

########################################################
# interactively remove (or not) each package file
function remove_pkg_files() {	

	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_file_regex ]] || [[ $file =~ $pkg_sig_file_regex ]]
		then
			while : 
			do
				msg0="Found an old package file: ${file##*/}"
				msg1="Delete it? [Y/n]"
				lib10k_get_user_response "$msg0" "$msg1"
				user_response_code="$?"
				[ "$user_response_code" -eq 2 ] && rm "$file" && break # yes; break while
				[ "$user_response_code" -eq 3 ] &&  break # no; break while
			done
		fi
	done

	return 0
} # end function

########################################################
#
function reconnect_expressvpn() {
	
	sudo systemctl restart NetworkManager.service
	

} # end function

########################################################