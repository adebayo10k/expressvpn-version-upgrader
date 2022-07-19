#!/bin/bash

	# These values came from https://www.expressvpn.com/latest#linux
	# Value need to be double quotes, as we're later doing variable expansion within a grep.
	
	#Ubuntu 64-bit
	pkg_arch_regex="_amd64"
	pkg_filename_ext_regex="\.deb"

	#Ubuntu 32-bit
	#pkg_arch_regex="_i386"
	#pkg_filename_ext_regex="\.deb"

	#Fedora 64-bit
	#pkg_arch_regex="\.x86_64"
	#pkg_filename_ext_regex="\.rpm"

	#Fedora 32-bit
	#pkg_arch_regex="\.i386"
	#pkg_filename_ext_regex="\.rpm"

	#Arch 64-bit
	#pkg_arch_regex="-x86_64"
	#pkg_filename_ext_regex="\.pkg\.tar\.xz"

	#Raspberry Pi OS
	#pkg_arch_regex="_armhf"
	#pkg_filename_ext_regex="\.deb"