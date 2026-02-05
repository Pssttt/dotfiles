if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting ""

set -gx TERM xterm-256color

# aliases
alias g git
alias lg lazygit
alias v nvim
alias ls eza
alias la "eza -A"
alias ll "eza -l --icons"
alias lla "eza -l -A --icons"

set -gx EDITOR nvim

set -gx EZA_CONFIG_DIR /Users/psst/.config/eza
set -gx XDG_CONFIG_HOME /Users/psst/.config

# fish_add_path /Users/psst/.spicetify

fzf --fish | source
zoxide init --cmd cd fish | source

trap clear WINCH

# pnpm
set -gx PNPM_HOME "/Users/psst/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
