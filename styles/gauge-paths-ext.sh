#!/bin/bash
# Glancebar: Gauge (Paths)
# Layout (two or three lines):
#   FOLDER  ⣿⣿⣿⠀⠀⠀ 45% 90k/200k Opus 4.6
#   pwd: /full/path/to/project  cwd: /full/path/to/current/dir
#   ext: ~/Other/project  /usr/local/share/thing
# Third line only appears when cwd is outside project_dir.
# Colors: green > 40% left, yellow 20-40%, orange 10-20%, red < 10%

input=$(cat)

# Parse all fields in one jq call
eval "$(echo "$input" | jq -r '
  @sh "model=\(.model.display_name // "Unknown")",
  @sh "project_dir=\(.workspace.project_dir // .cwd // .workspace.current_dir // "")",
  @sh "cwd=\(.cwd // .workspace.current_dir // "")",
  @sh "used=\(.context_window.used_percentage // "")",
  @sh "ctx_size=\(.context_window.context_window_size // 200000)",
  @sh "session_id=\(.session_id // "default")"
')"

folder=$(basename "$project_dir" | tr '[:lower:]' '[:upper:]')

# Format context window size
if [ $ctx_size -ge 1000000 ]; then
  ctx_fmt="$(echo "scale=0; $ctx_size/1000000" | bc)M"
elif [ $ctx_size -ge 1000 ]; then
  ctx_fmt="$(echo "scale=0; $ctx_size/1000" | bc)k"
else
  ctx_fmt="$ctx_size"
fi

dim='\033[38;5;240m'
label='\033[38;5;244m'
reset='\033[0m'

# Replace $HOME with ~ for readability
pretty_path() {
  local p=$1
  if [ -n "$HOME" ] && [ "${p#$HOME}" != "$p" ]; then
    printf '~%s' "${p#$HOME}"
  else
    printf '%s' "$p"
  fi
}

pwd_pretty=$(pretty_path "$project_dir")
cwd_pretty=$(pretty_path "$cwd")

# Build the paths line (always show both, even when equal, so the layout is stable)
paths_line=$(printf '%bpwd:%b %s  %bcwd:%b %s' \
  "$label" "$reset" "$pwd_pretty" "$label" "$reset" "$cwd_pretty")

# --- Track external directories across the session ---
tracker="/tmp/glancebar-dirs-${session_id}"
# Log current cwd if not already tracked
if [ -n "$cwd" ] && ! grep -qxF "$cwd" "$tracker" 2>/dev/null; then
  echo "$cwd" >> "$tracker"
fi

# Collect dirs that are NOT under project_dir
ext_dirs=""
if [ -f "$tracker" ] && [ -n "$project_dir" ]; then
  while IFS= read -r d; do
    case "$d" in
      "$project_dir"|"$project_dir"/*) ;; # skip subdirs of project
      *) ext_dirs="${ext_dirs:+$ext_dirs  }$(pretty_path "$d")" ;;
    esac
  done < "$tracker"
fi

# Build optional third line
ext_line=""
if [ -n "$ext_dirs" ]; then
  ext_line=$(printf '\n %bext:%b %s' "$label" "$reset" "$ext_dirs")
fi

# If no context data yet, just show folder + model + paths line
if [ -z "$used" ]; then
  printf ' %s  %s\n %b%b' "$folder" "$model" "$paths_line" "$ext_line"
  exit 0
fi

pct_used=${used%.*}
pct_remaining=$(( 100 - pct_used ))

# Calculate current context usage from percentage (not cumulative session totals)
current_tok=$(( pct_used * ctx_size / 100 ))
if [ $current_tok -ge 1000000 ]; then
  tok_fmt="$(echo "scale=1; $current_tok/1000000" | bc)M"
elif [ $current_tok -ge 1000 ]; then
  tok_fmt="$(echo "scale=0; $current_tok/1000" | bc)k"
else
  tok_fmt="$current_tok"
fi

# Color based on REMAINING threshold
if [ "$pct_remaining" -le 10 ]; then
  color='\033[1;31m'             # bold red
elif [ "$pct_remaining" -le 20 ]; then
  color='\033[38;5;208m'         # orange
elif [ "$pct_remaining" -le 40 ]; then
  color='\033[33m'               # yellow
else
  color='\033[32m'               # green
fi
empty='\033[38;5;237m'

# Build 6-block bar (dim ⣿ for empty blocks — same char width as filled)
bar_blocks=6
filled=$(( pct_used * bar_blocks / 100 ))
if [ $pct_used -gt 0 ] && [ $filled -eq 0 ]; then filled=1; fi

bar=""
i=0
while [ $i -lt $bar_blocks ]; do
  if [ $i -lt $filled ]; then bar="${bar}${color}⣿"; else bar="${bar}${empty}⣿"; fi
  i=$(( i + 1 ))
done
bar="${bar}${reset}"

printf ' %s  %b %d%% %s/%s %s\n %b%b' \
  "$folder" "$bar" "$pct_used" "$tok_fmt" "$ctx_fmt" "$model" "$paths_line" "$ext_line"
