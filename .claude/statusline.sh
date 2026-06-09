#!/bin/bash
input=$(cat)

# ── helpers ──────────────────────────────────────────────────────────────────
rgb()  { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bold() { printf '\033[1m'; }
dim()  { printf '\033[2m'; }
res()  { printf '\033[0m'; }

PIPE="$(dim)$(rgb 80 80 80)|$(res)"

# ── git repo name + branch ────────────────────────────────────────────────────
REPO_PART=""
CWD=$(echo "$input" | jq -r '.cwd // ""')
if git -C "$CWD" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    REPO_NAME=$(git -C "$CWD" --no-optional-locks rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
    BRANCH=$(git -C "$CWD" --no-optional-locks branch --show-current 2>/dev/null)
    REPO_PART="$(bold)$(rgb 220 180 0)${REPO_NAME}$(res) $(dim)$(rgb 80 80 80)|$(res) 🌿 $(bold)$(rgb 0 200 220)(${BRANCH})$(res)"
fi

# ── context window ────────────────────────────────────────────────────────────
USED_PCT_RAW=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$USED_PCT_RAW" ]; then
    USED_INT=$(printf '%.0f' "$USED_PCT_RAW")

    # percentage color by usage level
    if   [ "$USED_INT" -lt 40 ]; then PCT_COLOR=$(rgb 0 200 80)
    elif [ "$USED_INT" -lt 90 ]; then PCT_COLOR=$(rgb 220 200 0)
    else                               PCT_COLOR=$(rgb 220 40 20)
    fi

    CTX_PART="$(rgb 170 170 170)context:$(res) ${PCT_COLOR}${USED_INT}%$(res)"
else
    CTX_PART=""
fi

# ── session (5-hour) rate limit ───────────────────────────────────────────────
FIVE_PCT_RAW=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
SESSION_PART=""
if [ -n "$FIVE_PCT_RAW" ]; then
    FIVE_INT=$(printf '%.0f' "$FIVE_PCT_RAW")
    if   [ "$FIVE_INT" -le 40 ]; then S_COLOR=$(rgb 0 200 80)
    elif [ "$FIVE_INT" -le 80 ]; then S_COLOR=$(rgb 220 200 0)
    else                               S_COLOR=$(rgb 220 40 20)
    fi

    # time remaining until reset
    RESETS_AT=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
    TIME_LEFT_PART=""
    if [ -n "$RESETS_AT" ]; then
        NOW=$(date +%s)
        SECS_LEFT=$(( RESETS_AT - NOW ))
        if [ "$SECS_LEFT" -gt 0 ]; then
            HRS_LEFT=$(( SECS_LEFT / 3600 ))
            MINS_LEFT=$(( (SECS_LEFT % 3600) / 60 ))
            if [ "$HRS_LEFT" -gt 0 ]; then
                TIME_STR="${HRS_LEFT}h ${MINS_LEFT}m left"
            else
                TIME_STR="${MINS_LEFT}m left"
            fi
            TIME_LEFT_PART=" $(rgb 120 120 120)(${TIME_STR})$(res)"
        fi
    fi

    SESSION_PART="$(rgb 170 170 170)session:$(res) ${S_COLOR}${FIVE_INT}%$(res)${TIME_LEFT_PART}"
fi

# ── weekly (7-day) rate limit ─────────────────────────────────────────────────
WEEK_PCT_RAW=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEKLY_PART=""
if [ -n "$WEEK_PCT_RAW" ]; then
    WEEK_INT=$(printf '%.0f' "$WEEK_PCT_RAW")
    if   [ "$WEEK_INT" -le 40 ]; then W_COLOR=$(rgb 0 200 80)
    elif [ "$WEEK_INT" -le 80 ]; then W_COLOR=$(rgb 220 200 0)
    else                               W_COLOR=$(rgb 220 40 20)
    fi
    WEEKLY_PART="$(rgb 170 170 170)week:$(res) ${W_COLOR}${WEEK_INT}%$(res)"
fi

# ── model ─────────────────────────────────────────────────────────────────────
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
MODEL_PART="🤖 $(rgb 200 80 220)${MODEL}$(res)"

# ── assemble ──────────────────────────────────────────────────────────────────
OUT=""

append() {
    if [ -n "$1" ]; then
        if [ -n "$OUT" ]; then
            OUT="${OUT} ${PIPE} ${1}"
        else
            OUT="${1}"
        fi
    fi
}

append "$REPO_PART"
append "$CTX_PART"
append "$SESSION_PART"
append "$WEEKLY_PART"
append "$MODEL_PART"

printf '%b\n' "$OUT"
