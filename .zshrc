# -*- shell-script -*-
# ENV_IMPROVEMENT_ROOT will be set to the apollo root, this is done by
# $ENV_IMPROVEMENT_ROOT/var/zshrc, which is in turn created by the
# 200CreateZshrc function.  $ENV_IMPROVEMENT_ROOT/var/zshrc is where
# this file should be sourced from

# First we want to dispatch to the environment version of zsh, if available

ZSH_NAME=zsh            # TODO: why do we have to set this explicitly?
ZSH=$ENV_IMPROVEMENT_ROOT/var/bin/zsh

if [[ $SHELL != $ZSH && -e $ZSH ]]
then
  SHELL=$ZSH
  exec $ZSH "$@"
fi

# Gets the right, e.g., zle.so to load
ZSH_VERSION=${${(fz)"$($SHELL -f --version)"}[2]}

# source shell-neutral config:
source "$ENV_IMPROVEMENT_ROOT/dotfiles/anyshrc"

#################### important pre-external-hook vars ################
# path where zsh searches for modules (such as zle, the zsh line editor)
# you *want* this to work
module_path=($ENV_IMPROVEMENT_ROOT/var/lib/zsh/$ZSH_VERSION/)
\
# search path for zsh functions  (fpath ==> function path)
# Make sure the AmazonZshFunctions list comes second for overriding reasons
fpath=(                                                             \
        $ENV_IMPROVEMENT_ROOT/var/zsh/functions/$ZSH_VERSION        \
        $ENV_IMPROVEMENT_ROOT/var/share/zsh/$ZSH_VERSION/functions  \
      )

#################### external hooks ##################################
#Since we don't load these /etc files because of the way we compiled zsh, load
#them now.

if [[ -e /etc/zshenv ]]
then
  source /etc/zshenv
fi

if [[ -e /etc/zshrc ]]
then
  source /etc/zshrc
fi

#################### important zsh vars & common env vars ############
#
# Notes on the PATH varaible:
#   ENV_IMPROVEMENT_ROOT/bin should be early in the path, so that
#   it can override the /opt/third-party/bin paths
#
#   Since BrazilTools is deployed with the env improvement environment, we need
#   to put /apollo/env/SDETools/bin/ before the ROOT/bin since we want to pick
#   up the devtools-deployed versions first
#

export PATH=
path=(
       ~/bin
       ~/usr/bin
       /apollo/env/SDETools/bin
       $ENV_IMPROVEMENT_ROOT/bin
       /usr/local/bin
       /usr/bin
       /bin
       /usr/sbin
       /sbin
       /usr/local/sbin
       /usr/X11R6/bin
       /usr/X11/bin
       /apollo/bin
       /usr/kerberos/bin
       /opt/third-party/bin
       /opt/third-party/sbin
     )

typeset -ga precmd_functions
typeset -ga preexec_functions

autoload colors
colors

if [[ -z "$ZSH_THEME" ]]; then
    ZSH_THEME="default"
fi

source $ENV_IMPROVEMENT_ROOT/dotfiles/zsh.d/themes/$ZSH_THEME

if [[ -n "$ENABLE_VCS_INFO" ]]; then
    source $ENV_IMPROVEMENT_ROOT/dotfiles/zsh.d/vcs_info
fi

if [[ $AUTO_TITLE_SCREENS != "NO" && $EMACS != "t" ]]
then
    source $ENV_IMPROVEMENT_ROOT/dotfiles/zsh.d/auto_title_screens
fi

######################### aliases ####################################
#Don't alias grep until after sourcing the files above, could get bad version
#of grep that doesn't understand --color
alias grep='nocorrect grep --color=auto'

######################### key bindings ###############################
#set zsh key binding options
case $EDITOR in
  vi*|gvim*)
    bindkey -v  # VI is better than Emacs
    ;;
  emacs*|xemacs*)
    bindkey -e	# Emacs is better than VI
    ;;
esac
bindkey "^R" history-incremental-search-backward
bindkey "^E" end-of-line
bindkey "^A" beginning-of-line

#AWESOME...
#pushes current command on command stack and gives blank line, after that line
#runs command stack is popped
bindkey "^T" push-line-or-edit

# VI editing mode is a pain to use if you have to wait for <ESC> to register.
# This times out multi-char key combos as fast as possible. (1/100th of a
# second.)
KEYTIMEOUT=1

######################### zsh options ################################
setopt ALWAYS_TO_END	       # Push that cursor on completions.
setopt AUTO_NAME_DIRS          # change directories  to variable names
setopt AUTO_PUSHD              # push directories on every cd
setopt NO_BEEP                 # self explanatory

######################### history options ############################
setopt EXTENDED_HISTORY        # store time in history
setopt HIST_EXPIRE_DUPS_FIRST  # unique events are more usefull to me
setopt HIST_VERIFY	       # Make those history commands nice
setopt INC_APPEND_HISTORY      # immediatly insert history into history file
HISTSIZE=16000                 # spots for duplicates/uniques
SAVEHIST=15000                 # unique events guarenteed
HISTFILE=~/.history
setopt histignoredups          # ignore duplicates of the previous event


######################### completion #################################
# these are some (mostly) sane defaults, if you want your own settings, I
# recommend using compinstall to choose them.  See 'man zshcompsys' for more
# info about this stuff.

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl true

if [[ $IGNORE_APOLLO_1 != 'NO' ]]
then
  # Ignore /apollo_1 for directories.  That dir is an import directory
  zstyle ':completion:*' ignored-patterns '/apollo_1'
fi

autoload zmv
alias 'zcp=noglob zmv -W -C'
alias 'zln=noglob zmv -W -L'
alias 'zmv=noglob zmv -W -M'

autoload -U compinit
compinit
# End of lines added by compinstall


###################### command prompt additions ######################
if command -v __check_kinit >/dev/null
then
    precmd_functions+='__check_kinit'
fi



source /apollo/env/envImprovement/var/zshrc

export PATH=/apollo/env/eclipse-3.7/bin:$PATH:/home/quanlinc:$PATH:/apollo/env/Git/bin
export PAGER=cat
alias ll="ls -alF"
alias m="/home/quanlinc/emacs-24.3/src/emacs"
alias cls="clear"
alias clf="clear;ll"
alias makemasontags='find mason -iregex ".*\\(.m\\|.mi\\|\\.js\\|html\\|dhandler\\|autohandler\\)" -print | grep -v "#" | etags -'
alias bb="brazil-build"
alias bbp="brazil-build apollo-pkg"
alias run="ServiceSideTool.sh"
alias activate="sudo /apollo/bin/runCommand -a Activate"
alias deactivate="sudo /apollo/bin/runCommand -a Deactivate"


#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

autoload -U compinit
compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

# keep background processes at full speed
# setopt NOBGNICE
# restart running processes on exit
# setopt HUP

## history
#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0
export CLICOLOR=1
export LS_COLORS='di=33:fi=0:ln=95:pi=5:so=5:bd=5:cd=5:or=37:mi=0:ex=31:*.rpm=90'
autoload -U colors
colors






