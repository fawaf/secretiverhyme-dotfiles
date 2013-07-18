# vim:fdm=marker
# inspiration drawn from: {{{
#  - http://gentoo-wiki.com/Talk:Screen (check ca. mid-2008 on the WayBack Machine)
#  - http://zshwiki.org/home/examples/compquickstart
#  - http://grml.org/zsh/zsh-lovers.html
#  - http://aperiodic.net/phil/prompt/
#  - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
# }}}

# General options. {{{
bindkey -e                  # Emacs keybindings
export EDITOR=vim
export PAGER=less
setopt EXTENDED_GLOB
setopt PROMPT_SUBST         # Allow expansion and substitution in the prompt string
setopt SHARE_HISTORY        # Share history between multiple instances of zsh
setopt AUTO_LIST            # Show possible matches if completion can't figure out what to do
setopt AUTO_RESUME          # Treat single word simple commands without redirection as candidates for resumption of an existing job
setopt EXTENDED_HISTORY     # Put beginning and ending timestamps in the history file
setopt HIST_IGNORE_DUPS     # Give sequential duplicate commands only one history entry
setopt HIST_FIND_NO_DUPS    # Don't show duplicate commands when searching the history
setopt MAGIC_EQUAL_SUBST    # Do completion on <value> in foo=<value>
setopt NONOMATCH            # Don't error if globbing fails -- just leave the globbing chars in
setopt AUTO_CD              # Don't require `cd` to change directories
setopt NO_BEEP              # "I refer to this informally as the OPEN_PLAN_OFFICE_NO_VIGILANTE_ATTACKS option."
REPORTTIME=10               # Give timing statistics for programs that take longer than ten seconds to run
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=$HISTSIZE
# }}}

# Simple completion setup, lifted from ZshWiki. {{{
zmodload zsh/complist
autoload -U compinit && compinit
zstyle ':completion:::::' completer _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e)"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
# }}}

# Aliases. {{{
alias tmux='tmux -2'
alias xc='open *.xcodeproj'
alias ac='open -a AppCode *.xcodeproj'
alias xcb='xcodebuild'
alias ss='osascript -e "tell application \"System Events\" to start current screen saver"'
# }}}

# Useful functions. {{{

function collapse_pwd() {
    pwd | sed -e "s,^$HOME,~," -e "s,\([^/]\)[^/]*/,\1/,g"
}

function graceful_term() {
    # If ncurses is installed, use tput to gracefully degrade termtypes.
    if type tput >/dev/null; then # tput is installed
        local terminal_types
        set -A terminal_types screen-256color-bce screen-256color screen-bce \
                              screen xterm-256color xterm-color xtermc xterm \
                              vt100 dumb

        # find $TERM in $terminal_types
        while [[ -z $terminal_types[1] && $terminal_types[1] != $TERM ]]; do
            shift terminal_types
        done

        # as soon as we find a terminal type ncurses recognizes, choose it
        if [[ -z $terminal_types[1] ]]; then
            for TERMTYPE in $terminal_types; do
                if tput -T $TERMTYPE longname >/dev/null 2>/dev/null; then 
                    export TERM=$TERMTYPE
                    break
                fi
            done
        fi
    fi
}

function set_titlebar()
{  
    # Set either xterm's titlebar or screen's hardstatus.  (set_titlebar short-title descriptive-title)
    # eg., set_titlebar "user@host:~" "[~] command" in preexec()/precmd()
    case $TERM in
        xterm*)
            # set a descriptive title for xterms
            print -nR $'\033]0;'$2$'\a'
        ;;
        screen*)
            # set tab window title (%t)
            print -nR $'\033k'$1$'\033'\\\
            # and hardstatus of tab window (%h)
            print -nR $'\033]0;'$2$'\a'
        ;;
        *)
            # all other terminals -- don't do anything
        ;;
    esac
}

# }}}

# Initialization. {{{

# Set up convenience variables for coloring the prompt; borrowed from Phil!'s .zshrc.
autoload -U colors && colors
autoload zsh/terminfo
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$bold_color$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
done
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_BG_$color='%{$bold_color$bg[${(L)color}]%}'
done
PR_NO_COLOR="%{$reset_color%}"
unset color

# Set up vcs_info.
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' actionformats " on $PR_GREEN%b|%a"
zstyle ':vcs_info:*' formats " on $PR_GREEN%b"
zstyle ':vcs_info:git*:*' actionformats " on ±$PR_GREEN%b|%a"
zstyle ':vcs_info:git*:*' formats " on ±$PR_GREEN%b"

# Set up the prompt.
[[ `print -P '%n'` == "rhyme" && `print -P '%m'` == "reason" ]] && PR_AT_SYMBOL=' and ' || PR_AT_SYMBOL=' at '
PS1='%(!.$PR_WHITE$PR_BG_RED%n$PR_NO_COLOR.$PR_MAGENTA%n)$PR_NO_COLOR$PR_AT_SYMBOL$PR_YELLOW%m$PR_WHITE | $PR_GREEN`collapse_pwd`$PR_NO_COLOR${vcs_info_msg_0_}
%(!.$PR_WHITE$PR_BG_RED%#$PR_NO_COLOR.$PR_WHITE%#$PR_NO_COLOR) '
#RPS1='%(?..$PR_RED [%?]$PR_NO_COLOR)%(1j.$PR_CYAN [%j]$PR_NO_COLOR.)$PR_LIGHT_CYAN %T$PR_NO_COLOR'
PS2='$PR_WHITE%#$PR_NO_COLOR($PR_LIGHT_GREEN%_$PR_NO_COLOR) '

# Set up Screen integration. {{{
# Text to display {{{
# use current host as the prefix of the current tab title
TAB_TITLE_PREFIX='"`print -P %m`:"'		#='"${USER}@`print -P %m`:"'
# when at the shell prompt, show a truncated version of the current path (with
# standard ~ replacement) as the rest of the title.
TAB_TITLE_PROMPT='`print -Pn "%~" | sed "s:\([~/][^/]*\)/.*/:\1/.../:"`'
# when running a command, show the title of the command as the rest of the
# title (truncate to drop the path to the command)
TAB_TITLE_EXEC='`case $cmd[1]:t in ; "sudo") echo $cmd[2]:t;; *) echo $cmd[1]:t;; esac`'

# use the current path (with standard ~ replacement) in square brackets as the
# prefix of the tab window hardstatus.
TAB_HARDSTATUS_PREFIX='`print -Pn "[%~] "`'
# when at the shell prompt, use the shell name (truncated to remove the path to
# the shell) as the rest of the title
TAB_HARDSTATUS_PROMPT='$SHELL:t'
# when running a command, show the command name and arguments as the rest of
# the title
TAB_HARDSTATUS_EXEC='$cmd'
# }}}

# preexec() and precmd() {{{
# Called by zsh before executing a command:
function preexec()
{
    local -a cmd; cmd=(${(z)1})        # the command string
    eval "tab_title=$TAB_TITLE_PREFIX$TAB_TITLE_EXEC"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX$TAB_HARDSTATUS_EXEC"
    set_titlebar $tab_title $tab_hardstatus
}

# Called by zsh before showing the prompt:
function precmd()
{
    vcs_info
    eval "tab_title=$TAB_TITLE_PREFIX$TAB_TITLE_PROMPT"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX$TAB_HARDSTATUS_PROMPT"
    set_titlebar $tab_title $tab_hardstatus
}
# }}}
# }}}

# Activate zmv.
autoload -U zmv
alias mmv='noglob zmv -W'

# Checking whether build environment is sane ... build environment is grinning and holding a spatula.  Guess not.
alias woot="figlet woot | cowsay -n -f stegosaurus"

# Gracefully degrade if this machine can't handle the current $TERM type.
graceful_term

# Activate RVM, if applicable.
[[ -s ~/.rvm/scripts/rvm ]] && source ~/.rvm/scripts/rvm

# }}}
