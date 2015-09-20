#### CONFIG SPECIFIC VARIABLES ################################################
export C_SYS=`uname`
export C_PATH_TO_CONFIG=$HOME/.config_common
export C_PATH_TO_PERSONNAL_CONFIG=$HOME/.config_personnal

#### PATH #####################################################################
PATH=$HOME/bin:$PATH

# yes it could had been at the end with the other stuff relate to 42 but it's
# the PATH so I put it at begining
if [[ "$C_SYS" = "Darwin" ]]; then
    PATH=$HOME/.brew/bin:$PATH
    export PATH
fi

#### ZSH CONFIG ###############################################################
# zsh history
HISTFILE=~/.zshrc_history
SAVEHIST=5000
HISTSIZE=5000
setopt inc_append_history
setopt share_history

# previous/next word with ctrl + arrow
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# delete key
bindkey "\e[3~"   delete-char

# better autocomplete
autoload -U compinit && compinit

# autocomplete menu
zstyle ':completion:*' menu select

# prompt color
autoload -U colors && colors

#### LOAD GLOBAL STUFF ########################################################
# Load prompt file
if [[ -f "$C_PATH_TO_PERSONNAL_CONFIG/prompt" ]];
then
    source "$C_PATH_TO_PERSONNAL_CONFIG/prompt"
else
    source "$C_PATH_TO_CONFIG/prompt"
fi

# Load global aliases
source $C_PATH_TO_CONFIG/aliases

#### PERSONNAL STUFF ##########################################################

# Load personnal zshrc
if [[ -f "$C_PATH_TO_PERSONNAL_CONFIG/zshrc" ]]; then
    source "$C_PATH_TO_PERSONNAL_CONFIG/zshrc"
fi

# Load personnal aliases
if [[ -f "$C_PATH_TO_PERSONNAL_CONFIG/aliases" ]]; then
    source "$C_PATH_TO_PERSONNAL_CONFIG/aliases"
fi

# Add personnal scripts to path
if [[ -d "$C_PATH_TO_PERSONNAL_CONFIG/scripts" ]]; then
    PATH="$C_PATH_TO_PERSONNAL_CONFIG/scripts:$PATH"
fi

#### MAC SPECIFIC STUFF #######################################################
# Well, 42 instead of mac would be more accurate but, who use a mac ?)

if [[ "$C_SYS" == "Darwin" ]]; then
    # 42 variables definition
    USER=`/usr/bin/whoami`
    export USER
    GROUP=`/usr/bin/id -gn $user`
    export GROUP
    MAIL="$USER@student.42.fr"
    export MAIL

    # fucking mac and their /Volume/<hdd_name>
    cd "`echo $PWD | sed 's:/Volumes/Data::'`"

    # Alt-arrow to move from word to word
    bindkey "^[^[[C" forward-word
    bindkey "^[^[[D" backward-word

    # add completion provied by bin installed via brew
    if [[ -d "$HOME/.brew/share/zsh/site-functions/" ]]; then
        fpath=($HOME/.brew/share/zsh/site-functions/ $fpath)
    fi

    # update symlink in case of zsf change
    if [[ ! -f $HOME/.old_home ]]; then
        echo $HOME > $HOME/.old_home
    fi
    OLD_HOME=$(cat $HOME/.old_home)
    if [[ "$OLD_HOME" != "$HOME" ]]; then
        echo $HOME > $HOME/.old_home
        $C_PATH_TO_CONFIG/install.sh -u
        echo "+------------------------------------------------+"
        echo "|                                                |"
        echo "|             /!\\ You've changed zsf             |"
        echo "|                                                |"
        echo "| If you encounter issue with binaries installed |"
        echo "| via brew, you should use the command :         |"
        echo "| repare_brew                                    |"
        echo "| /!\\ This command may take some time            |"
        echo "+------------------------------------------------+"
    fi

    # reinstall brew and all the installed binaries
    function repare_brew ()
    {
        brew list > $HOME/.brew_list &&
        rm -rf $HOME/.brew && mkdir $HOME/.brew &&
        curl -L https://github.com/Homebrew/homebrew/tarball/master |
            tar xz --strip 1 -C $HOME/.brew &&
        mkdir -p $HOME/Library/Caches/Homebrew &&
        $HOME/.brew/bin/brew install `cat $HOME/.brew_list` &&
        rm $HOME/.brew_list
    }

    function next ()
    {
        nb=$(basename `pwd` | grep "ex")
        if [[ -n "$nb" ]]; then
            if [[ -n "$1" ]]; then inc=$1; else inc=1; fi
            nb=$(expr `echo $nb | tr -d "[a-z]"` + $inc)
            if [[ $nb -lt 10 ]]
            then
                dir="../ex0$nb"
            else
                dir="../ex$nb"
            fi
            mkdir -p $dir
            cd $dir
        fi
    }

    function prev ()
    {
        nb=$(basename `pwd` | grep "ex")
        if [[ -n "$nb" ]]; then
            if [[ -n "$1" ]]; then dec=$1; else dec=1; fi
            nb=$(expr `echo $nb | tr -d "[a-z]"` - $dec)
            if [[ $nb -lt 0 ]]
            then
                dir="../ex00"
            elif [[ $nb -lt 10 ]]
            then
                dir="../ex0$nb"
            else
                dir="../ex$nb"
            fi
            cd $dir
        fi
    }
fi
