# vim:fdm=marker
# Environment. {{{
umask 077                   # Deny group/world rwx by default (useful on multiuser systems)
export LANG="en_US.UTF-8"
# }}}

# Try to be a little more intelligent about PATH and MANPATH.  May introduce duplicate entries. {{{
for directory in ~/Applications/sw/bin ~/bin ~/.rvm/bin /opt/local/sbin /opt/local/bin /usr/local/sbin /usr/local/bin /usr/local/games /usr/games/bin; do
    [ -d $directory ] && PATH=$directory:$PATH
done
for directory in /opt/local/share/man /usr/games/man; do
    [ -d $directory ] && MANPATH=$directory:$MANPATH
done
unset directory
# }}}

# Handle local zshenv. {{{
if [ -f ~/.zshenv-local ]; then
    source ~/.zshenv-local
fi
# }}}
