#### PATH #####################################################################
# yes it could had been at the end with the other stuff relate to 42 but it's
# the PATH so I put it at begining
if [[ "$C_SYS" == "Darwin" ]] && [[ -z "$C_SYS" ]]; then
    PATH=$HOME/.brew/bin:$PATH
    export PATH
fi

#### CONFIG SPECIFIC VARIABLES ################################################
C_SYS=`uname`
C_PATH_TO_CONFIG=$HOME/.config_common
C_PATH_TO_PERSONNAL_CONFIG=$HOME/.config_personnal

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

# Correction de la touche Delete
bindkey "\e[3~"   delete-char

# Autocompletion amelioree
autoload -U compinit && compinit

# Autocompletion de type menu
zstyle ':completion:*' menu select

# Couleur prompt
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

#### MAC SPECIFIC STUFF #######################################################
# Well, 42 instead of mac would be more accurate but, who use a mac ?)

if [[ "$C_SYS" == "Darwin" ]]; then
    # Definition des variables
    USER=`/usr/bin/whoami`
    export USER
    GROUP=`/usr/bin/id -gn $user`
    export GROUP
    MAIL="$USER@student.42.fr"
    export MAIL

    # fucking mac and their /Volume/<hdd_name>
    cd "`echo $PWD | sed 's:/Volumes/Data::'`"

    # Alt-arrow to move from word to word
    bindkey "^[[1;3C" forward-word
    bindkey "^[[1;3D" backward-word

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
        echo "+------------------------+"
        echo "| /!\\ You've changed zsf |"
        echo "+------------------------+"
    fi
fi
