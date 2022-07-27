#!/bin/bash
#
linux_pkg_dl_landing_page="https://www.expressvpn.com/latest#linux"

downloads_dir="$HOME/Downloads"

pkg_file_regex="^${downloads_dir}/expressvpn[-_]{1}[0-9\.-]*.*(deb|rpm|xz)$"
pkg_sig_file_regex="^${downloads_dir}/expressvpn[-_]{1}[0-9\.-]*.*(deb|rpm|xz)\.asc$"

declare -a os_platforms=(
	"Ubuntu_64_bit"
	"Ubuntu_32_bit"
	"Fedora_64_bit"
	"Fedora_32_bit"
	"Arch_64_bit"
	"Raspberry_Pi_OS"
)

