#!/bin/bash

# PATHS
export CONF_PATH=$HOME/.config_common
export PERS_PATH=$HOME/.config_personnal

function usage()
{
    echo "Sorry, no help for the time being"
    exit 0
}

function do_ln()
{
    unset SRC DEST
    if [[ -n "$1" ]]; then
        if [[ ${1:0:1} == "/" ]]; then
            SRC=$1
        else
            SRC="$PERS_PATH/$1"
        fi
    fi
    if [[ -n "$2" ]]; then
        if [[ ${2:0:1} == "/" ]]; then
            DEST=$2
        else
            DEST="$HOME/$2"
        fi
    fi
    if [[ -n "$SRC" ]] && [[ -n "$DEST" ]] && [[ -f "$SRC" ]]; then
        if [[ -e "$DEST" ]]; then
            if [[ "$INS_FORCE" == "OK" ]]; then
                rm -rf "$DEST"
            else
                mv "$DEST" "$DEST.back"
            fi
        fi
        ln -sf "$SRC" "$DEST"
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

if [[ `uname` == "Darwin" ]]; then
    BREW_CACHE="$HOME/Library/Caches/Homebrew"
    if [[ ! -e "$BREW_CACHE" ]]; then
        mkdir -p "$BREW_CACHE"
    fi
    /usr/local/bin/brew update
    if [[ -f $PERS_PATH/brew_tap ]]; then
        for line in `cat $PERS_PATH/brew_tap`
        do
            if [[ ${line:0:1} != "#" ]]; then
                $HOME/.brew/bin/brew tap $line
            fi
        done
    fi
    if [[ -f $PERS_PATH/brew_apps ]]; then
        $HOME/.brew/bin/brew install `cat $PERS_PATH/brew_apps` ||
        for line in `cat $PERS_PATH/brew_apps`
        do
            $HOME/.brew/bin/brew install $line ||
                echo "Error while installing $line"
        done
    fi
fi

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
    do_ln $CONF_PATH/zshrc $HOME/.zshrc
    if [[ -f "$PERS_PATH/ln" ]]; then
        OIFS=$IFS
        for FILE in `cat "$PERS_PATH/ln"`
        do
            IFS=":"
            do_ln $FILE
            IFS=$OIFS
        done
    fi
    if [[ `uname` == "Darwin" ]]; then
        rm -rf $HOME/.brew/share/zsh/site-functions/_brew
        ln -s $CONF_PATH/_brew $HOME/.brew/share/zsh/site-functions/_brew
    fi
fi
