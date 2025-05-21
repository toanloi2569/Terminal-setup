unalias gco 2>/dev/null

gco() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: gco [mode]"
    echo "  mode: 'time' (default) - list branches by last update"
    echo "        'name'           - list branches by name"
    echo
    echo "Select a branch to checkout using fzf with git preview."
    echo "Example:"
    echo "  gco           # List by last update"
    echo "  gco name      # List by name"
    echo "  gco --help    # Show this help"
    return 0
  fi

  local mode="${1:-time}"
  [[ $# -gt 0 ]] && shift

  local branch selected
  if [[ "$mode" == "name" ]]; then
    selected=$(git for-each-ref --sort=refname --format='%(refname:short)' refs/heads/ | \
      fzf --no-sort \
          --prompt="Checkout branch (by name): " \
          --height=30% \
          --preview="git log -1 --color=always --oneline --decorate --stat {}" \
          --preview-window=right:60%:wrap)
    branch="$selected"
  else
    selected=$(git for-each-ref --sort=-committerdate \
      --format='%(refname:short) | %(committerdate:relative)' refs/heads/ | \
      fzf --no-sort \
          --prompt="Checkout branch (by last update): " \
          --height=30% \
          --preview="echo {} | cut -d'|' -f1 | xargs -r git log -1 --color=always --oneline --decorate --stat" \
          --preview-window=right:60%:wrap)
    branch=$(printf "%s" "$selected" | sed 's/|.*//;s/ *$//')
  fi

  if [[ -n "$branch" ]]; then
    git checkout "$branch"
    echo "On branch: $(git branch --show-current)"
  else
    echo "❌ No branch selected."
  fi
}

git_helper_commands() {
    local commands=(
      "gco: Checkout a branch by name or last update"
    )

    for cmd in "${commands[@]}"; do
        echo "$cmd"
    done
}
