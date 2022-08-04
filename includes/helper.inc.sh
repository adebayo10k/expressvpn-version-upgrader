#!/bin/bash
# This is a helper script to help "the human" to interface appropriately
# with "the program". 

#########################
# GLOBAL VARIABLE DECLARATIONS:
#########################
declare -i max_expected_no_of_program_parameters=1
declare -i min_expected_no_of_program_parameters=0
declare -ir actual_no_of_program_parameters=$#
run_mode=${1:-''}

#########################
# FUNCTION DECLARATIONS:
#########################

#
function check_all_program_conditions() {
	local program_dependencies=("expressvpn" "gpg" "dpkg" "curl")
	lib10k_check_no_of_program_args
	# validate program parameters
	validate_program_args
	[ $? -eq 0 ] || usage
	# check program dependencies, exit 1 if can't even do that
	lib10k_check_program_dependencies "${program_dependencies[@]}" || exit 1
}

# 
function validate_program_args() {
	[ -z "$run_mode" ] && return 0
	[ -n "$run_mode" ] && [ $run_mode = 'dev' ] && return 0
	[ -n "$run_mode" ] && [ $run_mode = 'help' ] && return 1
	[ -n "$run_mode" ] && return 1
}

# This function always exits program
function usage () {

	cat <<_EOF	
Usage:	$command_basename [dev|help]

Checks a public web page for latest product information.
Optionally downloads, verifies and installs latest package.

Be aware that this program is an interesting workaround, but 
relies on a public data source that is not guaranteed to persist.
It should therefore not really be used outside of hobby and 
development environments.
Read the source, extend and test if you wish.

dev	Run program in development only mode.

help	Show this text.

_EOF

exit 0
}

