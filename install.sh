#!/bin/bash

# PATHS
export CONF_PATH=$HOME/.config_common
export PERS_PATH=$HOME/.config_personal

# is it 42 school ?
if [[ `uname` == "Darwin" ]] && [[ -e '/goinfre' ]]; then
    export SCHOOL42=yes
fi

function usage()
{
    RED='\033[0;31m'
    NC='\033[0m'
    TMP_PP=`echo $PERS_PATH | tr '/' ':'`
    TMP_HOME=`echo $HOME | tr '/' ':'`
    PERS_PATH_C="\033[0;32m${TMP_PP/$TMP_HOME/~}"
    PERS_PATH_C=`echo $PERS_PATH_C | tr ':' '/'`
    echo "Usage: $0 [-h] [-f] [-u] [-b] [-p <git repository>]"
    echo -e "\t$RED-h$NC: display this help"
    echo -e "\t$RED-f$NC: apply force arg on command in the script if available"
    echo -e "\t$RED-u$NC: delete and recreate the symlink based on $PERS_PATH_C/ln$NC"
    echo -e "\t$RED-b$NC: install brew, tap repo in $PERS_PATH_C/brew_tap$NC and install $PERS_PATH_C/brew_apps$NC"
    echo -e "\t$RED-p$NC: clone your config in $PERS_PATH_C"$NC
    echo -e "\nThis config can work with a personal one in which you could put some specific files:"
    echo -e "\t"$RED"install.sh$NC: this script will be called when using -p arg"
    echo -e "\t"$RED"aliases   $NC: put your aliases in this file it will be sourced with zshrc"
    echo -e "\t"$RED"brew_app  $NC: all the apps to install with brew with -b arg"
    echo -e "\t"$RED"brew_tap  $NC: all the repo to add to brew"
    echo -e "\t"$RED"ln        $NC: all the symlink to create with -u arg"
    echo -e "\t"$RED"prompt    $NC: if you want to have a different prompt than the common one"
    echo -e "\t"$RED"zshrc     $NC: if you want to extand the common zshrc, do it it this file"
    echo -e "\nFor more complete explanation, report to \033[0;34mgithub.com/geam/config_common\033[0m"
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
                usage
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
            -b)
                BREW="OK"
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
fi

if [[ `uname` == "Darwin" ]] && [[ "$BREW" == "OK" ]]; then
    BREW_CACHE="$HOME/Library/Caches/Homebrew"
    if [[ ! -e "$BREW_CACHE" ]]; then
        mkdir -p "$BREW_CACHE"
    fi
    /usr/local/bin/brew update
    if [[ $0 -ne 0 ]]; then
        mkdir $HOME/.brew &&
        curl -L https://github.com/Homebrew/homebrew/tarball/master |
            tar xz --strip 1 -C $HOME/.brew
    fi
    if [[ -f $PERS_PATH/brew_tap ]]; then
        for line in `cat $PERS_PATH/brew_tap`
        do
            if [[ ${line:0:1} != "#" ]]; then
                $HOME/.brew/bin/brew tap $line
            fi
        done
    fi
    $HOME/.brew/bin/brew update
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
    if [[ -f "$PERS_PATH/install.sh" ]]; then
        bash "$PERS_PATH/install.sh"
    fi
fi

if [[ -n "$INS_UP_LN" ]]; then
    rm -rf $HOME/.zshrc
    cd
    ln -sf .config_common/zshrc .zshrc
    cd - > /dev/null
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
        if [[ ! -e $HOME/.brew/share/site-functions ]]; then
            mkdir -p "$HOME/.brew/share/site-functions"
        fi
        rm -rf $HOME/.brew/share/zsh/site-functions/_brew
        ln -s $CONF_PATH/_brew $HOME/.brew/share/zsh/site-functions/_brew
    fi
fi
