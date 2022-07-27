#!/bin/bash
#
linux_pkg_dl_landing_page="https://www.expressvpn.com/latest#linux"

downloads_dir="$HOME/Downloads"

pkg_file_regex="^${downloads_dir}/expressvpn[-_]{1}[0-9\.-]*.*(deb|rpm|xz)$"
pkg_sig_file_regex="^${downloads_dir}/expressvpn[-_]{1}[0-9\.-]*.*(deb|rpm|xz)\.asc$"

#"U64" "U32" "RPi"
user_selected_platform="U64"


