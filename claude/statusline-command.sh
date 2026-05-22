#!/usr/bin/env bash
# Claude Code status line
# Receives JSON on stdin from Claude Code

input=$(cat)

# https://code.claude.com/docs/en/statusline
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
session=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
session_next=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_next=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
weekly=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ANSI colors (dim-friendly)
RES='\033[0m'
DIM='\033[2m'
ITA='\033[3m'
RED='\033[31m'
GRN='\033[32m'
YEL='\033[33m'
CYA='\033[36m'
ORG='\e[38;2;218;119;86m' # Claude orange

parts=()

# Model (shortened)
if [[ -n $model ]]
then
    short_model=$(echo "$model" | sed 's/Claude //' | sed 's/ Sonnet/S/' | sed 's/ Haiku/H/' | sed 's/ Opus/O/')

    # Effort
    if [[ -n $effort ]]
    then
        case "$effort" in
            low)      eff_color="$GRN" ;;
            medium)   eff_color="$YEL" ;;
            high)     eff_color="$ORG" ;;
            xhigh)    eff_color="$ORG" ;;
            max)      eff_color="$RED" ;;
            *)        eff_color="$RED" ;;
        esac
        parts+=("$(printf '%s/%s' "${GRN}$short_model${RES}" "${eff_color}$effort${RES}")")
    fi
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

# Rate limits
if [[ -n $session && -n $weekly ]]
then
    rate_part() {
        local label="$1" val="$2"
        local val_int color
        val_int=$(printf '%.0f' "$val")
        if (( val_int >= 80 ))
        then
            color="$RED"
        elif (( val_int >= 50 ))
        then
            color="$YEL"
        else
            color="$GRN"
        fi
        printf "%s: ${color}$val_int%%${RES}" "$label"
    }

    session_str=$(rate_part "Session" "$session")
    if [[ -n $session_next ]]
    then
        session_str+=" $DIM$ITA(${CYA}>> $(date -d "@$session_next" +%H:%M)$RES$DIM$ITA)$RES"
    fi
    week_str=$(rate_part "Week" "$weekly")
    if [[ -n $week_next ]]
    then
        week_str+=" $DIM$ITA(${CYA}>> $(date -d "@$week_next" +'%a %d')$RES$DIM$ITA)$RES"
    fi
    parts+=("$session_str $week_str")
fi

joinByString() {
  local separator="$1"
  shift
  local first="$1"
  shift
  printf "%s" "$first" "${@/#/$separator}"
}

# Result
printf '%b' "$(joinByString ' | ' "${parts[@]}")"
