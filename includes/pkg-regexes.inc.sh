#!/bin/bash
#
linux_pkg_dl_landing_page="https://www.expressvpn.com/latest#linux"

# These values come from $linux_pkg_dl_landing_page
# Values need to be double quoted, as we're later doing variable expansion within a grep.
########################################################
#Ubuntu 64-bit
U64_pkg_arch_regex="_amd64"
U64_pkg_fn_ext_regex="\.deb"
#Ubuntu 32-bit
U32_pkg_arch_regex="_i386"
U32_pkg_fn_ext_regex="\.deb"
#Fedora 64-bit
F64_pkg_arch_regex="\.x86_64"
F64_pkg_fn_ext_regex="\.rpm"
#Fedora 32-bit
F32_pkg_arch_regex="\.i386"
F32_pkg_fn_ext_regex="\.rpm"
#Arch 64-bit
A64_pkg_arch_regex="-x86_64"
A64_pkg_fn_ext_regex="\.pkg\.tar\.xz"
#Raspberry Pi OS
RPi_pkg_arch_regex="_armhf"
RPi_pkg_fn_ext_regex="\.deb"

# This is a placeholder for platform detection functionality
detected_plat="U64"

# 
case $detected_plat in
	'U64') pkg_arch_regex=$U64_pkg_arch_regex; pkg_fn_ext_regex=$U64_pkg_fn_ext_regex
			;;
    'U32') pkg_arch_regex=$U32_pkg_arch_regex; pkg_fn_ext_regex=$U32_pkg_fn_ext_regex
			;;
    'F64') pkg_arch_regex=$F64_pkg_arch_regex; pkg_fn_ext_regex=$F64_pkg_fn_ext_regex
			;;
    'F32') pkg_arch_regex=$F64_pkg_arch_regex; pkg_fn_ext_regex=$F64_pkg_fn_ext_regex
			;;
    'A64') pkg_arch_regex=$A64_pkg_arch_regex; pkg_fn_ext_regex=$A64_pkg_fn_ext_regex
			;;
    'RPi') pkg_arch_regex=$RPi_pkg_arch_regex; pkg_fn_ext_regex=$RPi_pkg_fn_ext_regex
			;;
	*)	    msg="Unknown Linux Platform. Exiting now..."
            lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
			;;
esac

pkg_file_url_regex=\
"href=\"https://www.expressvpn.works/clients/linux/expressvpn_[0-9\.-]*${pkg_arch_regex}${pkg_fn_ext_regex}\""

