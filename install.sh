#!/bin/bash

# PATHS
CONF_PATH=$HOME/.config_common
PERS_PATH=$HOME/.config_personnal

function usage()
{
	echo "Sorry, no help for the time being"
	exit 0
}

function do_ln()
{
	if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -f "$PERS_PATH/$1" ]]; then
		if [[ -e "$HOME/$2" ]]; then
			rm -rf "$HOME/$2"
		fi
		ln -s "$PERS_PATH/$1" "$HOME/$2"
	fi
}

# get the arg of the script
while test $# -gt 0
do
	if [[ "${1:0:2}" == '--' ]]
	then
		case $1 in
			--help)
				usage
				;;
			--force)
				INS_FORCE=OK
				;;
			--personnal)
				shift
				INS_PERS=$1
				;;
			*)
				echo "Unknown option $1"
				usage
				;;
		esac
	elif [[ "${1:0:1}" = '-' ]]
	then
		case $1 in
			-h)
				echo "help"
				;;
			-p)
				shift
				INS_PERS="$1"
				;;
			-f)
				INS_FORCE="OK"
				;;
			-u)
				INS_UP_LN="OK"
				;;
			*)
				echo "Unknown option $1"
				usage
				;;
		esac
	fi
	shift
done

if [[ -n "$INS_PERS" ]]; then
	if [[ -e "$PERS_PATH" ]];
	then
		if [[ "$INS_FORCE" != "OK" ]]; then
			echo "A personnal config is already present, replace it ?[y/N] " -e DONE
		fi
		if [[ "$DONE" = "y" ]] || [[ "$DONE" = "Y" ]] || [[ "$INS_FORCE" = "OK" ]]
		then
			rm -rf "$PERS_PATH"
		fi
	fi
	git clone "$INS_PERS" "$PERS_PATH"
	if [[ "$?" -ne 0 ]]; then
		echo "An error has occur while cloning personnal config"
		exit 1
	fi
	if [[ -f "$PERS_PATH/install.sh" ]]; then
		bash "$PERS_PATH/install.sh"
	fi
fi

if [[ -n "$INS_UP_LN" ]]; then
	rm -rf $HOME/.zshrc
	ln -s $CONF_PATH/zshrc $HOME/.zshrc
	if [[ -f "$PERS_PATH/ln" ]]; then
		OIFS=$IFS
		for FILE in `cat "$PERS_PATH/ln"`
		do
			IFS=":"
			do_ln $FILE
			IFS=$OIFS
		done
	fi
fi
