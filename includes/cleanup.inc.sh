#!/bin/bash
# This module is responsible for putting the host back into a state in which \
# it was found, regarding downloaded files.
########################################################

# remove downloaded package installation and signature files.
function cleanup_and_revert() {
	while :
	do
		# Get user permission to proceed...
		question_string='Interactively Delete old Package and Signature file downloads? (recommended). Enter Number'
		responses_string='Yes(Delete) No(Skip)'
		get_user_binary_exclusive_response "$question_string" "$responses_string"
		user_response_code="$?"
		# affirmative case
		if [ "$user_response_code" -eq 1 ]; then
			echo "Continuing..."
			remove_pkg_files
			break
		else
			# negative case || unexpected case
			break
		fi
	done
	echo && echo "The End." && echo
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
				msg0="Found an old package file:"
				echo &&	echo "$msg0"
				echo && echo "${file}" && echo
				# Get user permission to proceed...
				question_string='Delete this old package file? Enter Number'
				responses_string='Yes(Delete) No(Keep)'
				get_user_binary_exclusive_response "$question_string" "$responses_string"
				user_response_code="$?"
				# affirmative case
				if [ "$user_response_code" -eq 1 ]; then
					echo && echo "Deleting..."
					echo && rm "$file"
					break
				else
					# negative case || unexpected case
					break
				fi
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