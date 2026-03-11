#!/bin/bash
# Glancebar: Gauge (Colorblind-safe)
# A context-aware statusline for Claude Code
# Shows: PROJECT  ⣿⣿⣿⠀⠀⠀ 45% 90k/200k Opus 4.6  [cwd]
#
# 6-block braille meter fills up as context is consumed
# Colors: blue (>40% left) → cyan (20-40%) → yellow (10-20%) → bold magenta (<10%)
# Uses blue-orange-safe palette — fully distinguishable with red-green color deficiency
# Working directory shown in brackets only when different from project root

input=$(cat)

# Parse all fields in one jq call
eval "$(echo "$input" | jq -r '
  @sh "model=\(.model.display_name // "Unknown")",
  @sh "project_dir=\(.workspace.project_dir // .cwd // .workspace.current_dir // "")",
  @sh "cwd=\(.cwd // .workspace.current_dir // "")",
  @sh "used=\(.context_window.used_percentage // "")",
  @sh "ctx_size=\(.context_window.context_window_size // 200000)"
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

# If no context data yet, just show folder + model
if [ -z "$used" ]; then
  printf ' %s  %s' "$folder" "$model"
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

# Colorblind-safe palette (no red-green distinction needed)
if [ "$pct_remaining" -le 10 ]; then
  color='\033[1;35m'             # bold magenta (critical)
elif [ "$pct_remaining" -le 20 ]; then
  color='\033[33m'               # yellow (warning)
elif [ "$pct_remaining" -le 40 ]; then
  color='\033[36m'               # cyan (caution)
else
  color='\033[34m'               # blue (normal)
fi
reset='\033[0m'

# Build 6-block all-or-nothing bar
bar_blocks=6
filled=$(( pct_used * bar_blocks / 100 ))
if [ $pct_used -gt 0 ] && [ $filled -eq 0 ]; then filled=1; fi

bar="${color}"
i=0
while [ $i -lt $bar_blocks ]; do
  if [ $i -lt $filled ]; then bar="${bar}⣿"; else bar="${bar}⠀"; fi
  i=$(( i + 1 ))
done
bar="${bar}${reset}"

# Working directory suffix (only if different from project dir)
cwd_suffix=""
if [ -n "$cwd" ] && [ "$cwd" != "$project_dir" ]; then
  # Show relative path from project dir
  rel_cwd="${cwd#$project_dir/}"
  if [ "$rel_cwd" != "$cwd" ]; then
    cwd_suffix="  [$rel_cwd]"
  else
    short_cwd=$(basename "$cwd")
    cwd_suffix="  [$short_cwd]"
  fi
fi

printf ' %s  %b %d%% %s/%s %s%s' \
  "$folder" "$bar" "$pct_used" "$tok_fmt" "$ctx_fmt" "$model" "$cwd_suffix"
