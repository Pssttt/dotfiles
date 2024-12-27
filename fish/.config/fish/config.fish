if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting ""

set -gx TERM xterm-256color

# aliases
alias g git
alias lg lazygit
alias sp spotify_player
alias v nvim
alias ls eza
alias la "eza -A"
alias ll "eza -l --icons"
alias lla "eza -l -A --icons"

set -gx EZA_CONFIG_DIR /Users/psst/.config/eza
set -gx XDG_CONFIG_HOME /Users/psst/.config

fish_add_path /Users/psst/.spicetify
