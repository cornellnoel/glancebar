#!/bin/bash
# Glancebar Preview
# Run: bash preview/preview.sh
# Shows the Gauge style at every percentage with live terminal colors

reset='\033[0m'
dim='\033[38;5;240m'
underline='\033[4m'

get_color() {
  local remaining=$(( 100 - $1 ))
  if [ "$remaining" -le 10 ]; then printf '\033[1;31m'
  elif [ "$remaining" -le 20 ]; then printf '\033[38;5;208m'
  elif [ "$remaining" -le 40 ]; then printf '\033[33m'
  else printf '\033[32m'
  fi
}

render_bar() {
  local pct=$1
  local filled=$(( pct * 6 / 100 ))
  if [ $pct -gt 0 ] && [ $filled -eq 0 ]; then filled=1; fi
  local color=$(get_color $pct)
  local bar=""
  for (( i=0; i<6; i++ )); do
    if [ $i -lt $filled ]; then bar="${bar}⣿"; else bar="${bar}⠀"; fi
  done
  printf "${color}%s${reset}" "$bar"
}

echo ""
echo "  Glancebar: Gauge"
echo "  ────────────────"
echo ""
printf "  ${dim}%-12s  %-12s %-4s %-9s %-9s  %-6s${reset}\n" \
  "PROJECT" "METER" "USED" "TOKENS" "MODEL" "COLOR"
printf "  ${dim}%-12s  %-12s %-4s %-9s %-9s  %-6s${reset}\n" \
  "───────" "─────" "────" "──────" "─────" "─────"

for pct in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
  bar=$(render_bar $pct)
  tok=$(( pct * 2 ))
  remaining=$(( 100 - pct ))
  if [ "$remaining" -le 10 ]; then label="${dim}red${reset}"
  elif [ "$remaining" -le 20 ]; then label="${dim}orange${reset}"
  elif [ "$remaining" -le 40 ]; then label="${dim}yellow${reset}"
  else label="${dim}green${reset}"
  fi
  printf "  MY PROJECT  %b %3d%% %3dk/200k Opus 4.6  %b\n" "$bar" "$pct" "$tok" "$label"
done

echo ""
printf "  ${dim}With working directory:${reset}\n"
bar=$(render_bar 45)
printf "  MY PROJECT  %b  45%% 90k/200k Opus 4.6  ${dim}[src/components]${reset}\n" "$bar"
echo ""
