#!/bin/bash
# Glancebar Preview
# Run: bash preview/preview.sh
# Shows Gauge style at every percentage with live terminal colors

reset='\033[0m'
dim='\033[38;5;240m'

get_color() {
  local remaining=$(( 100 - $1 ))
  if [ "$remaining" -le 10 ]; then printf '\033[1;31m'
  elif [ "$remaining" -le 20 ]; then printf '\033[38;5;208m'
  elif [ "$remaining" -le 40 ]; then printf '\033[33m'
  else printf '\033[32m'
  fi
}

get_color_cb() {
  local remaining=$(( 100 - $1 ))
  if [ "$remaining" -le 10 ]; then printf '\033[1;35m'
  elif [ "$remaining" -le 20 ]; then printf '\033[33m'
  elif [ "$remaining" -le 40 ]; then printf '\033[36m'
  else printf '\033[34m'
  fi
}

empty='\033[38;5;237m'

render_bar() {
  local pct=$1 color_fn=$2
  local filled=$(( pct * 6 / 100 ))
  if [ $pct -gt 0 ] && [ $filled -eq 0 ]; then filled=1; fi
  local color=$($color_fn $pct)
  local bar=""
  for (( i=0; i<6; i++ )); do
    if [ $i -lt $filled ]; then bar="${bar}${color}⣿"; else bar="${bar}${empty}⣿"; fi
  done
  printf "%b${reset}" "$bar"
}

print_table() {
  local title=$1 color_fn=$2 color_labels=$3

  echo ""
  echo "  $title"
  printf "  ${dim}──────────────────────────────────────────────────────────────────${reset}\n"
  # Header bar rendered through same render_bar path as data rows
  get_color_dim() { printf '\033[38;5;240m'; }
  header_bar=$(render_bar 100 get_color_dim)
  printf "  %-12s %b %5s  %-10s %-10s ${dim}%s${reset}\n" \
    "PROJECT" "$header_bar" "USED" "TOKENS" "MODEL" "COLOR"
  printf "  ${dim}──────────────────────────────────────────────────────────────────${reset}\n"

  IFS=',' read -ra labels <<< "$color_labels"

  for pct in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
    bar=$(render_bar $pct $color_fn)
    tok=$(( pct * 2 ))
    remaining=$(( 100 - pct ))
    if [ "$remaining" -le 10 ]; then label="${dim}${labels[3]}${reset}"
    elif [ "$remaining" -le 20 ]; then label="${dim}${labels[2]}${reset}"
    elif [ "$remaining" -le 40 ]; then label="${dim}${labels[1]}${reset}"
    else label="${dim}${labels[0]}${reset}"
    fi
    printf "  %-12s %b %4d%%  %4dk/200k %-10s %b\n" \
      "MY PROJECT" "$bar" "$pct" "$tok" "Opus 4.6" "$label"
  done

  printf "  ${dim}──────────────────────────────────────────────────────────────────${reset}\n"
  echo ""
  printf "  ${dim}With working directory:${reset}\n"
  bar=$(render_bar 45 $color_fn)
  printf "  %-12s %b %4d%%  %4dk/200k %-10s ${dim}[src/components]${reset}\n" \
    "MY PROJECT" "$bar" 45 90 "Opus 4.6"
  echo ""
}

get_color_gs() {
  local remaining=$(( 100 - $1 ))
  if [ "$remaining" -le 10 ]; then printf '\033[1;7m'
  elif [ "$remaining" -le 20 ]; then printf '\033[1m'
  elif [ "$remaining" -le 40 ]; then printf '\033[0m'
  else printf '\033[2m'
  fi
}

print_table "Glancebar: Gauge" "get_color" "green,yellow,orange,red"
print_table "Glancebar: Gauge (Colorblind-safe)" "get_color_cb" "blue,cyan,yellow,magenta"
print_table "Glancebar: Gauge (Grayscale)" "get_color_gs" "dim,normal,bright,inverse"
