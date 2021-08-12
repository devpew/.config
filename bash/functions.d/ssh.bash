#!/usr/bin/env bash

# SSH functions
# https://github.com/rafi/.config

# Yank selected public key with fzf and pbcopy
pubkey() {
	cert="$(find ~/.ssh -type f -name "*.pub" -printf "%P\n" | fzf)"
	if [ -n "$cert" ]; then
		pbcopy < "$HOME/.ssh/$cert"
		echo "=> Public key yanked."
	fi
}

# Super SSH: safe terminfo, persist user name, tmux window name
ssh() {
	# Use safest terminfo on remote server
	if [ -n "$TMUX" ]; then
		TERM=screen-256color
	else
		TERM=xterm
	fi
	# Don't overwrite environment variable if it's not empty
	export LC_IDENTIFICATION="${LC_IDENTIFICATION:-$USER}"
	# Rename tmux window
	[ -n "$TMUX" ] && tmux rename-window "${@: -1}" 1>/dev/null
	# Execute ssh with identification
	command ssh -o SendEnv=LC_IDENTIFICATION "$@"
	# Reset tmux window name
	[ -n "$TMUX" ] && tmux set-window-option automatic-rename "on" 1>/dev/null
}

# Immediately attach/start a tmux session on remote server
ssht() {
	ssh "$*" -t '
		PATH="$HOME/.local/bin:$HOME/bin:$PATH";
		tmux attach 2>/dev/null || tmux -S $HOME/tmux attach || tmux || /bin/bash'
}

# vim: set ts=2 sw=2 tw=80 noet :