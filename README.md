# expressvpn-version-upgrader

## About this Project

Expressvpn is a pretty popular VPN provider. I've been using their service for a few years now. Not bad at all.

Reading around it seems that at time of writing, expressvpn doesn't yet deposit packages into a ppa. Instead, the recommended process for acquiring their latest packages involves GUI browser opening and mouse clicking.

Anyway, being a Linux user I prefer using their CLI program as my VPN client. Also, being a Linux user it's never long before I start trying to write scripts to automate stuff. This project is about automating the quite frequent process of updating to the latest client version.

This program has so far been tested only on 64-bit Ubuntu (20.04) Linux and with its' default, built-in BASH interpreter.

## Files
- expressvpn-version-upgrader.sh - the main script file.
- includes/cleanup.inc.sh - included functions related to file cleanup and restoring.
- includes/pkg-installation.inc.sh - included functions relating to the actual package installation.
- includes/pkg-regexes.inc.sh - included text file listing of flavours of Linux supported by expressvpn.
- includes/setup.inc.sh - functions included to prepare for the install.

- shared-functions-library/shared-bash-constants.inc.sh - common module.
- shared-functions-library/shared-bash-functions.inc.sh - common module.

## Purpose

I suppose this program is a bit of a workaround, until expressvpn make their packages available from their ppa.

So this program, written for bash, automates the update process. It is interactive. Only the actual `dpkg -i` install command needs `sudo` privilege, so it didn't seem reasonable to give the program to the root user. 

The program completes the package version update from the command line in just a few seconds, prompting the user at several stages during the following sequence of events:

0. Quick check that the basic dependencies are installed.
1. Display the currently installed expressvpn package version.
2. Retrieve the URL of the latest expressvpn package version from expressvpn.
3. Download the latest expressvpn package file.
4. GnuPG verify the downloaded expressvpn package file.
5. Install the expressvpn package file.
6. Clean up and remove downloaded files.
7. Reconnect to the expressvpn network.


## Dependencies

("expressvpn" "gpg" "dpkg" "curl" "nmcli")

Unless part of the default Ubuntu Desktop build, the programs I chose to do the work of downloading files etc. are the ones I prefer to use.

## Requirements

To do any package install on your system, sudo privilege is required.

## Prerequisites

It is assumed that you're already using an activated instance of the expressvpn Ubuntu Linux client.

In order to verify the downloaded package file, you'll also need have imported the expressvpn public key into your gpg keyring. A reasonably decent [guide to verifying package file authenticity](https://www.expressvpn.com/support/vpn-setup/pgp-for-linux/) is provided by expressvpn.

NOTE: PGP and GnuPG are effectively synonymous as far as I recall.

## Installation

If you have all the above prerequisites covered, you're ready to clone, test, use and extend away.

This project includes the separate shared-functions-library repository as a submodule. The clone command must therefore include the `--recurse-submodules` option which will initialise and fetch changes from the submodule repository, like so...

``` bash
git clone --recurse-submodules https://github.com/adebayo10k/expressvpn-version-upgrader.git

```

That done, you can optionally create a symbolic link file in a directory in your `PATH` that targets your cloned expressvpn-version-upgrader.sh executable, something like...

```
ln -s path-to-cloned-repo-root-directory/expressvpn-version-upgrader.sh ~/${USER}/bin/expressvpn-version-upgrader.sh
```


## Configuration

The _pkg-regexes.inc.sh_ file lists the Linux flavour and Platforms/CPU architectures that are apparently supported by expressvpn.
So far, this program has only been configured for the 64-bit Ubuntu client version, although I'm assuming that extending this should be pretty trivial.

### Configuration Side Note:

Nothing to do with this project, but I've also configured my cron table with this line to get expressvpn to start trying to connect at boot time. The 20 second delay was necessary on my slow-bootin, old laptop.

```
@reboot sleep 20; bash -c "expressvpn connect" >/dev/null 2>>"$HOME/cronjob-errors.log"
```

## Parameters

None.


## Running the Script

Internet connectivity is required at runtime, as the program does a couple of cURLs to the expressvpn domain.

If you've symlinked from a directory in your `PATH`, then just execute...
``` bash
expressvpn-version-upgrader.sh
```

... else, execute expressvpn-version-upgrader.sh from within your Git project root directory with...

```
cd path-to-cloned-repo-root-directory && \
./expressvpn-version-upgrader.sh
```

## Logging

None.

## License
No changes or additions. See [LICENCE](./LICENSE).


