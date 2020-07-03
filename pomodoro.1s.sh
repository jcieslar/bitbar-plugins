#!/bin/bash
#
# <bitbar.title>Pomodoro Timer</bitbar.title>
# Base on:
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Goran Gajic</bitbar.author>
# <bitbar.author.github>gorangajic</bitbar.author.github>
# <bitbar.desc>Pomodoro Timer that uses Pomodoro Technique™</bitbar.desc>
# <bitbar.image>http://i.imgur.com/T0zFY89.png</bitbar.image>

WORK_TIME=25
BREAK_TIME=5
LONG_BREAK_TIME=20

SAVE_LOCATION=$TMPDIR/bitbar-promodo
TOMATO='🍅'

WORK_TIME_IN_SECONDS=$((WORK_TIME * 60))
BREAK_TIME_IN_SECONDS=$((BREAK_TIME * 60))
LONG_BREAK_TIME_IN_SECONDS=$((LONG_BREAK_TIME * 60))

CURRENT_TIME=$(date +%s)

if [ -f "$SAVE_LOCATION" ];
then
    DATA=$(cat "$SAVE_LOCATION")

else
    DATA="$CURRENT_TIME|0|0"
fi

TIME=$(echo "$DATA" | cut -d "|" -f1)
STATUS=$(echo "$DATA" | cut -d "|" -f2)
HISTORY=$(echo "$DATA" | cut -d "|" -f3)

function changeStatus {
    echo "$CURRENT_TIME|$1|$4" > "$SAVE_LOCATION";
    osascript -e "display notification \"$2\" with title \"$TOMATO Pomodoro\" sound name \"$3\"" &> /dev/null
}

function breakMode {
    HISTORY=$((HISTORY+2))
    changeStatus "2" "Break Mode" "Glass" $HISTORY
}

function longBreakMode {
    HISTORY=0
    changeStatus "3" "Long Break Mode" "Glass" $HISTORY
}

function workMode {
    HISTORY=$((HISTORY+1))
    changeStatus "1" "Work Mode" "Blow" $HISTORY
}

function doBreak {
    if (($HISTORY >= 7));
    then
        longBreakMode
    else
        breakMode
    fi

}

case "$1" in
"work")
    workMode
    exit
  ;;
"break")
    breakMode
    exit
  ;;
"long_break")
    longBreakMode
    exit
  ;;
"disable")
    changeStatus "0" "Disabled"
    exit
  ;;
esac



function timeLeft {
    local FROM=$1
    local TIME_DIFF=$((CURRENT_TIME - TIME))
    local TIME_LEFT=$((FROM - TIME_DIFF))
    echo "$TIME_LEFT";
}

function getSeconds {
    echo $(($1 % 60))
}

function getMinutes {
    echo $(($1 / 60))
}

function printTime {
    SECONDS=$(getSeconds "$1")
    MINUTES=$(getMinutes "$1")
    printf "%s %02d:%02d| color=%s\n" "$TOMATO" "$MINUTES" "$SECONDS"  "$2"
}

case "$STATUS" in
# STOP MODE
"0")
    echo "$TOMATO"
  ;;
"1")
    TIME_LEFT=$(timeLeft $WORK_TIME_IN_SECONDS)
    if (( "$TIME_LEFT" < 0 )); then
        doBreak
    fi
    printTime "$TIME_LEFT" "red"
  ;;
"2")
    TIME_LEFT=$(timeLeft $BREAK_TIME_IN_SECONDS)
    if (("$TIME_LEFT" < 0)); then
        workMode
    fi
    printTime "$TIME_LEFT" "green"
  ;;
"3")
    TIME_LEFT=$(timeLeft $LONG_BREAK_TIME_IN_SECONDS)
    if (("$TIME_LEFT" < 0)); then
        workMode
    fi
    printTime "$TIME_LEFT" "green"
  ;;
esac

echo "---";
echo "💻 Work | bash=\"$0\" param1=work terminal=false"
echo "☕ Break | bash=\"$0\" param1=break terminal=false"
echo "🍕 Long break | bash=\"$0\" param1=long_break terminal=false"
echo "🔌 Disable | bash=\"$0\" param1=disable terminal=false"
