#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
  install_stow
  local -a packages=($(find "$REPO_DIR" -maxdepth 1 -type d ! -name '.*' ! -name 'dotfiles' -exec basename {} \; | sort))

  [[ ${#packages[@]} -eq 0 ]] && {
    echo "No packages found"
    exit 1
  }

  echo "Packages:"
  for i in "${!packages[@]}"; do
    echo "  $((i + 1)). ${packages[$i]}"
  done
  echo "  0. Exit"
  echo ""

  read -p "Select (space-separated numbers, or 'all'): " -r input

  [[ "$input" == "0" ]] && exit 0

  local -a to_install
  if [[ "$input" == "all" ]]; then
    to_install=("${packages[@]}")
  else
    for num in $input; do
      ((num > 0 && num <= ${#packages[@]})) && to_install+=("${packages[$((num - 1))]}")
    done
  fi

  [[ ${#to_install[@]} -eq 0 ]] && {
    echo "No packages selected"
    exit 0
  }

  cd "$REPO_DIR"
  for pkg in "${to_install[@]}"; do
    [[ -d "$pkg" ]] && stow "$pkg" -t "$HOME" && echo "✓ $pkg" || echo "✗ $pkg not found"
  done
}

install_stow() {
  command -v stow &>/dev/null && return
  echo "installing Stow"
  if command -v brew &>/dev/null; then
    brew install stow
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y stow
  else
    echo "Error: brew/apt-get not found"
    exit 1
  fi
}

main "$@"
