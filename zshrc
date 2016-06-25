#### CONFIG SPECIFIC VARIABLES ################################################
export C_SYS=`uname`
if [[ -e /goinfre ]]; then
    export C_SCHOOL=YES
fi
export C_PATH_TO_CONFIG=$HOME/.config_common
export C_PATH_TO_PERSONAL_CONFIG=$HOME/.config_personal

#### PATH and FPATH ###########################################################
PATH=$HOME/bin:$PATH

# yes it could had been at the end with the other stuff relate to 42 but it's
# the PATH so I put it at begining
if [[ "$C_SYS" = "Darwin" ]]; then
    PATH=$HOME/.brew/bin:$PATH
    export PATH

    # add completion provied by bin installed via brew
    if [[ -d "$HOME/.brew/share/zsh/site-functions" ]]; then
        fpath=($HOME/.brew/share/zsh/site-functions $fpath)
    fi

fi

#### ZSH CONFIG ###############################################################
# zsh history
HISTFILE=~/.zsh_history
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
if [[ -f "$C_PATH_TO_PERSONAL_CONFIG/prompt" ]];
then
    source "$C_PATH_TO_PERSONAL_CONFIG/prompt"
else
    source "$C_PATH_TO_CONFIG/prompt"
fi

# add prompt_hook to precmd hook list
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions prompt_hook)

# Load global aliases
source $C_PATH_TO_CONFIG/aliases

#### PERSONAL STUFF ###########################################################

# Load personal zshrc
if [[ -f "$C_PATH_TO_PERSONAL_CONFIG/zshrc" ]]; then
    source "$C_PATH_TO_PERSONAL_CONFIG/zshrc"
fi

# Load personal aliases
if [[ -f "$C_PATH_TO_PERSONAL_CONFIG/aliases" ]]; then
    source "$C_PATH_TO_PERSONAL_CONFIG/aliases"
fi

# Add personal scripts to path
if [[ -d "$C_PATH_TO_PERSONAL_CONFIG/scripts" ]]; then
    PATH="$C_PATH_TO_PERSONAL_CONFIG/scripts:$PATH"
fi

#### MAC SPECIFIC STUFF #######################################################

if [[ $C_SYS == "Darwin" ]]; then
    # Alt-arrow to move from word to word
    bindkey "^[^[[C" forward-word
    bindkey "^[^[[D" backward-word
fi

#### 42 SCHOOL SPECIFIC STUFF #################################################

if [[ -n "$C_SCHOOL" ]]; then
    # 42 variables definition
    USER=`/usr/bin/whoami`
    export USER
    GROUP=`/usr/bin/id -gn $user`
    export GROUP
    MAIL="$USER@student.42.fr"
    export MAIL

    # fucking mac and their /Volume/<hdd_name>
    cd "`echo $PWD | sed 's:/Volumes/Data::'`"

    ## sometimes, the caches directory is not created and it's symlink is fucked
    ## up
    #if [[ ! -e /tmp/library.$USER/Caches ]]; then
    #    mkdir /tmp/Library.$USER/Caches
    #    rm -rf $HOME/Library/Caches
    #    cd $HOME/Library
    #    ln -s /tmp/library.$USER/Caches
    #    cd - 2>&1 > /dev/null
    #fi

    # Homebrew cache directory
    export HOMEBREW_CACHE=/tmp/$USER/brew_caches
    export HOMEBREW_TEMP=/tmp/$USER/brew_temp
    HOMEBREW_LOCKS=/tmp/$USER/brew_locks
    HOMEBREW_LOCKS_HOME=/$HOME/.brew/Library/Locks
    if [[ ! -d $HOMEBREW_CACHE ]]; then
        mkdir -p $HOMEBREW_CACHE
    fi
    if [[ ! -d $HOMEBREW_TEMP ]]; then
        mkdir -p $HOMEBREW_TEMP
    fi
    if [[ ! -d $HOMEBREW_LOCKS ]]; then
        mkdir -p $HOMEBREW_LOCKS
    fi
    if [[ ! -L $HOMEBREW_LOCKS_HOME ]]; then
        if [[ -d $HOMEBREW_LOCKS_HOME ]]; then
            rm -r $HOMEBREW_LOCKS_HOME
        fi
        ln -s $HOMEBREW_LOCKS $HOMEBREW_LOCKS_HOME
    fi
    unset HOMEBREW_LOCKS_HOME HOMEBREW_LOCKS

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

    function remove_header ()
    {
        for file in `find . -name "*.[ch]"`
        do
            if [[ `head -1 "$file"` == '/* ************************************************************************** */' ]];
            then
                nb_line=$(echo "`cat $file | wc -l` - 12" | bc)
                mv "$file" "$file.back"
                tail -"$nb_line" "$file.back" > "$file"
            fi
        done
    }

    function add_header ()
    {
        for file in `find . -name "*.[ch]"`
        do
            if [[ `head -1 "$file"` != '/* ************************************************************************** */' ]];
            then
                /usr/bin/vim -u /usr/share/vim/vimrc +Stdheader +wq $file
            fi
        done
    }
fi
