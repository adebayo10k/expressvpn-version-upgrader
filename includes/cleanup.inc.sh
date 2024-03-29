#!/bin/bash
# This module is responsible for putting the host back into a state in which \
# it was found, regarding downloaded files.
########################################################

# remove downloaded package installation and signature files.
function cleanup_and_revert() {
    local original_dir="$1"
    local downloads_dir="$2"
    local pkg_file_regex="$3"
    local pkg_sig_file_regex="$4"
	# Get user permission to proceed...
	question_string='Interactively Delete old Package and Signature file downloads? (recommended). Choose an option'
	responses_string='Yes, start Interactive Delete|No, Skip'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# affirmative case
	if [ "$user_response_code" -eq 1 ]; then
		echo "Continuing..."
		remove_pkg_files "$downloads_dir" "$pkg_file_regex" "$pkg_sig_file_regex"
	fi

	# cd back to the original program shell directory
	if [ -n "$original_dir" ] && (cd "$original_dir" >/dev/null 2>&1); then
		cd "$original_dir" >/dev/null 2>&1
	fi
	echo && echo "The End." && echo
} # end function

########################################################
# interactively remove (or not) each package file
function remove_pkg_files() {
    local downloads_dir="$1"
    local pkg_file_regex="$2"
    local pkg_sig_file_regex="$3"
	for file in "${downloads_dir}"/*
	do
		if [[ $file =~ $pkg_file_regex ]] || [[ $file =~ $pkg_sig_file_regex ]]
		then
			msg0="Found an old package file:"
			echo &&	echo -e "${BLUE}${msg0}${NC}"
			echo && echo -e "${BLUE}${file}${NC}" && echo
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
# this function can only be based on your own specific configurations of:
# - your network manager
# - your expressvpn preferences
# - ...
function reconnect_expressvpn() {
	:
	# sudo systemctl restart NetworkManager.service
	# nmcli ...
	# expressvpn preferences set ...
} # end function

########################################################