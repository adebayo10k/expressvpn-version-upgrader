#!/bin/sh
# These functions are responsible for handling dev user
# interaction with the program.

# passed a question and possible responses
# returns a user_response_num integer
# expect 2 incoming params, (not assumed):
# A single string for the question.
# A single string containing 2 or more IFS separated responses.
function get_user_response() {
	# check number of parameters
	if [ $# -ne 2 ]
	then
		msg="Incorrect number of params passed to function."
		lib10k_exit_with_error "$E_INCORRECT_NUMBER_OF_ARGS" "$msg"
	fi
	# assign parameters to variables
	question_string="$1"
	responses_string="$2"

	# expand and separate the responses into array elements
	OIFS=$IFS
	IFS='|'
	response_list=( $responses_string )

	user_response_num=''
    PS3="> "
    echo "$question_string : " && echo
	select response in ${response_list[@]}
	do
		# type error case
		if [[ ! $REPLY =~ ^[0-9]{1}$ ]] 
		then
			echo && echo "No option selected. Integer [1 - ${#response_list[@]}] Required. Try Again." && echo
			continue
		# out of bounds integer error case
		elif [ $REPLY -lt 1 ] || [ $REPLY -gt ${#response_list[@]} ]
		then
			echo && echo "Invalid selection. Integer [1 - ${#response_list[@]}] Required. Try Again." && echo
			continue
		# valid integer case
		elif [ $REPLY -ge 1 ] && [ $REPLY -le ${#response_list[@]} ] 
		then		
			echo && echo "You Selected : ${response}"
			user_response_num="${REPLY}"
			break
		# unexpected, failsafe case
		else		
			msg="Unexpected branch entered!"
			lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
		fi
	done
	IFS=$OIFS
	return "$user_response_num"	
} 

function get_user_platform_choice() {
	#
    echo 'Select your OS Platform to check online for VPN client updates (or choose None): ' && echo
    PS3="> "
	select platform in ${os_platforms[@]} 'None'
	do
		case $platform in 
		"Ubuntu_64_bit")
			echo && echo "You Selected the \"$platform\" OS platform." && echo
			user_selected_os_platform="$platform"
			break
			;;
		"Ubuntu_32_bit")
			echo && echo "You Selected the \"$platform\" OS platform." && echo
			user_selected_os_platform="$platform"
			break
			;;
		"Fedora_64_bit")
			echo && echo "You Selected the \"$platform\" OS platform." && echo
			user_selected_os_platform="$platform"
			break
			;;
		"Fedora_32_bit")
			echo && echo "You Selected the \"$platform\" OS platform." && echo
			user_selected_os_platform="$platform"
			break
			;;
		"Arch_64_bit")
			echo && echo "You Selected the \"$platform\" OS platform." && echo
			user_selected_os_platform="$platform"
			break
			;;
		"Raspberry_Pi_OS")
			echo && echo "You Selected the \"$platform\" OS platform. Nice! " && echo
			user_selected_os_platform="$platform"
			break
			;;
		'None')
			echo && echo "You Selected \"$platform\". Cannot continue."
			echo && exit 0 # END PROGRAM
			;;
		*) echo && echo "Invalid Selection. Integer [1 - $(( ${#os_platforms[@]} + 1 ))] Required. Try Again."
			continue
			;;
		esac
	done

	os_not_tested
}

function os_not_tested() {
	run_mode=${run_mode:-'default'}
	os_advisory0="This program has not been tested on the \"$platform\" OS platform."
    
	case $user_selected_os_platform in
	'Ubuntu_64_bit'|'Raspberry_Pi_OS') 
		if [ -n $run_mode ] && [ $run_mode != 'dev' ]
		then
			echo -e "${BROWN}${os_advisory0}${NC}" && echo 	 
			echo && usage
		fi
		;;
	"Ubuntu_32_bit")
		echo -e "${BROWN}${os_advisory0}${NC}" && echo 
		echo && usage
		;;
	"Fedora_64_bit")
		echo -e "${BROWN}${os_advisory0}${NC}" && echo 
		echo && usage
		;;
	"Fedora_32_bit")
		echo -e "${BROWN}${os_advisory0}${NC}" && echo 
		echo && usage
		;;
	"Arch_64_bit")
		echo -e "${BROWN}${os_advisory0}${NC}" && echo 
		echo && usage
		;;
	*) msg="We shouldn't be here!"
		lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
		;;
	esac
}


