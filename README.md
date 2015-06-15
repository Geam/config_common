# General trunc of my config

## Why a general trunc ?
Many people use my config at school and don't agree with all the modification I
want to do so 2 options :
- I don't do what I want to do to not bother them
- I do it because I really want it, sorry guys

The thing is, when I find something fun which can help with the mac a 42, they
need to update so they take the modification.

## Solution
I split my config in 2
- global stuff for everyone
- personnal stuff
This repo is the global one

## What did it provied ?
- Some usefull alias
- Basic configuration for zsh
- Install script that help at school with the zfs change

## How to use
### Clone it
First, you need to clone it in "$HOME/.config_common"
```bash
git clone https://github.com/Geam/config.git $HOME/.config_common
```
### Run it
Then run it
```bash
$HOME/.config_common/install.sh <options>
```
### Options
- -u : Update the symbolic link
- -f|--force : Doesn't ask question, do it
- -p|--personnal <url_to_personnal_git_repo> : you need to pass the url to your
  personnal config repo and it will clone it
- -h|--help : display help

### Personnal config
Well, it's just a repo with your file inside.
#### Specific files
- install.sh : If you provied a install.sh in your personnal repo, the global
  install.sh will run it
- ln : the global install.sh will make symbolic link to all this files in $HOME
  prefix with a dot
- prompt : it should only contain the prompt you wich to use, if not provied,
  the general one will be use
- zshrc : the global zshrc will source it at the end of it's own execution
