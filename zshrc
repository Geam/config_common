# Definition of variables used by config
C_SYS=`uname`
C_PATH_TO_CONFIG=XXXX

# Definition du PATH
if [[ "$C_SYS" == "Darwin" ]]; then
    PATH=$HOME/scripts:$HOME/.brew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/texbin
    export PATH
fi

# Configuration de l'historique
HISTFILE=~/.zshrc_history
SAVEHIST=5000
HISTSIZE=5000
setopt inc_append_history
setopt share_history

# Tmux command history
bindkey '^R' history-incremental-search-backward
bindkey -e
export LC_ALL=en_US.UTF-8

# search in history based on what is type
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward

# previous/next word with ctrl + arrow
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# default editor
EDITOR=/usr/bin/vim
export EDITOR

# Reglage du terminal
if [ "$SHLVL" -eq 1 ]; then
    TERM=xterm-256color
fi

# Correction de la touche Delete
bindkey "\e[3~"   delete-char

if [[ "$C_SYS" == "Darwin" ]]; then
    # add completion provied by bin installed via brew
    if [[ -d "$HOME/.brew/share/zsh/site-functions/" ]]; then
        fpath=($HOME/.brew/share/zsh/site-functions/ $fpath)
    fi
fi

# Autocompletion amelioree
autoload -U compinit && compinit

# Autocompletion de type menu
zstyle ':completion:*' menu select

# Couleur prompt
autoload -U colors && colors

if [[ "$C_SYS" == "Darwin" ]]; then
    # fucking mac and their /Volume/<hdd_name>
    cd "`echo $PWD | sed 's:/Volumes/Data::'`"
fi

# Definition des variables
USER=`/usr/bin/whoami`
export USER
GROUP=`/usr/bin/id -gn $user`
export GROUP
MAIL="$USER@student.42.fr"
export MAIL


if [[ -f "$C_PATH_TO_CONFIG/personnal/prompt" ]];
then
    source "$C_PATH_TO_CONFIG/personnal/prompt"
else
    source "$C_PATH_TO_CONFIG/prompt"
fi

# Load global aliases
if [[ -f ~/.aliases ]]; then
    source ~/.aliases
fi

# Load personnal aliases
if [[ -f "$C_PATH_TO_CONFIG/personnal/aliases" ]];then
    source "$C_PATH_TO_CONFIG/personnal/aliases"
fi

if [[ "$C_SYS" == "Darwin" ]]; then
    # update symlink in case of zsf change
    if [[ ! -f $HOME/.old_home ]]; then
        echo $HOME > $HOME/.old_home
    fi
    OLD_HOME=$(cat $HOME/.old_home)
    if [[ "$OLD_HOME" != "$HOME" ]]; then
        echo $HOME > $HOME/.old_home
        if [[ `basename $HOME` = "mdelage" ]]; then
            env GEAM=true $HOME/.dotfiles/install.sh -c -l
        else
            $HOME/.dotfiles/install.sh -c -l
        fi
        echo "+------------------------+"
        echo "| /!\\ You've changed zsf |"
        echo "+------------------------+"
    fi
fi
