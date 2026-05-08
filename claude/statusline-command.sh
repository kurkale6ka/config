#!/usr/bin/env bash
# Claude Code status line
# Receives JSON on stdin from Claude Code

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI colors (dim-friendly)
RES='\033[0m'
YEL='\033[33m'
GRN='\033[32m'
RED='\033[31m'

parts=()

# Model (shortened)
if [[ -n $model ]]
then
    short_model=$(echo "$model" | sed 's/Claude //' | sed 's/ Sonnet/S/' | sed 's/ Haiku/H/' | sed 's/ Opus/O/')
    parts+=("$(printf '%s' "${GRN}$short_model${RES}")")
fi

# Context usage
if [[ -n $used ]]
then
    used_int=$(printf '%.0f' "$used")
    if (( used_int >= 80 ))
    then
        ctx_color="$RED"
    elif (( used_int >= 50 ))
    then
        ctx_color="$YEL"
    else
        ctx_color="$GRN"
    fi
    parts+=("$(printf "context: ${ctx_color}${used_int}%%${RES}")")
fi

# Join with separator
printf '%b' "$(IFS=' | '; echo "${parts[*]}")"
