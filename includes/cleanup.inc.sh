#!/bin/bash
# This module is responsible for putting the host back into a state in which \
# it was found, regarding downloaded files.
########################################################

# remove downloaded package installation and signature files.
function cleanup_and_revert() {
	# Get user permission to proceed...
	question_string='Interactively Delete old Package and Signature file downloads? (recommended). Choose an option'
	responses_string='Yes, start Interative Delete|No, Skip'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# affirmative case
	if [ "$user_response_code" -eq 1 ]; then
		echo "Continuing..."
		remove_pkg_files
	fi

	echo && echo "The End." && echo
} # end function

########################################################
# interactively remove (or not) each package file
function remove_pkg_files() {
	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_file_regex ]] || [[ $file =~ $pkg_sig_file_regex ]]
		then
			msg0="Found an old package file:"
			echo &&	echo "$msg0"
			echo && echo "${file}" && echo
			# Get user permission to proceed...
			question_string='Delete this old package file? Choose an option'
			responses_string='Yes, Delete|No, Keep'
			get_user_response "$question_string" "$responses_string"
			user_response_code="$?"
			# affirmative case
			if [ "$user_response_code" -eq 1 ]; then
				echo && echo "Deleting..."
				echo && rm "$file"
			fi
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