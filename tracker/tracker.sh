#!/bin/bash

TIME_TRACK_FILE="$(dirname "$0")/time_tracking.json"
VISUALIZER_SCRIPT="$(dirname "$0")/visualize.py"

start_tracking() {
    TOPIC="$1"
    if [[ -z "$TOPIC" ]]; then
        echo "Error: No topic provided."
        return
    fi

    START_TIME=$(date +%s)
    START_TIME_FORMATTED=$(date -d @"$START_TIME" +"%H:%M:%S")

    if [ -f "$TIME_TRACK_FILE" ]; then
        TRACK_DATA=$(cat "$TIME_TRACK_FILE")
    else
        TRACK_DATA='{}'
    fi

    if echo "$TRACK_DATA" | jq -e ".\"$TOPIC\"" > /dev/null; then
        TRACK_DATA=$(echo "$TRACK_DATA" | jq --arg topic "$TOPIC" --argjson start_time "$START_TIME" --arg start_time_formatted "$START_TIME_FORMATTED" \
            '.[$topic].start_time = $start_time | .[$topic].start_time_formatted = $start_time_formatted')
    else
        TRACK_DATA=$(echo "$TRACK_DATA" | jq --arg topic "$TOPIC" --argjson start_time "$START_TIME" --arg start_time_formatted "$START_TIME_FORMATTED" \
            '.[$topic] = {"start_time": $start_time, "start_time_formatted": $start_time_formatted, "day": "unknown", "total_time": 0, "end_time": null, "end_time_formatted": null, "end_times": []}')
    fi

    echo "$TRACK_DATA" > "$TIME_TRACK_FILE"
    echo "Started tracking time for topic: $TOPIC at $START_TIME_FORMATTED."
}

stop_tracking() {
    TOPIC="$1"

    if [[ -z "$TOPIC" ]]; then
        echo "Please specify a topic to stop tracking."
        return
    fi

    if [ ! -f "$TIME_TRACK_FILE" ]; then
        echo "No tracking data found."
        return
    fi

    TRACK_DATA=$(cat "$TIME_TRACK_FILE")

    if [[ -z "$TOPIC" ]]; then
        if [ "$(echo "$TRACK_DATA" | jq 'keys | length')" -eq 0 ]; then
            echo "No topics have been tracked yet."
            return
        fi
        TOPIC=$(echo "$TRACK_DATA" | jq -r 'keys | last')
    fi

    if ! echo "$TRACK_DATA" | jq -e ".\"$TOPIC\"" > /dev/null; then
        echo "Topic '$TOPIC' not found in tracking data."
        return
    fi

    START_TIME=$(echo "$TRACK_DATA" | jq ".\"$TOPIC\".start_time")
    START_TIME_FORMATTED=$(echo "$TRACK_DATA" | jq -r ".\"$TOPIC\".start_time_formatted")
    if [ "$START_TIME" == "null" ]; then
        echo "Topic '$TOPIC' is not currently being tracked."
        return
    fi

    END_TIME=$(date +%s)
    TIME_SPENT=$(( END_TIME - START_TIME ))
    DAY_OF_WEEK=$(date -d @"$END_TIME" +%A)
    DATE=$(date -d @"$END_TIME" +%Y-%m-%d)
    END_TIME_FORMATTED=$(date -d @"$END_TIME" +"%H:%M:%S")

    TRACK_DATA=$(echo "$TRACK_DATA" | jq --arg topic "$TOPIC" --arg day "$DAY_OF_WEEK" --argjson time "$TIME_SPENT" --arg date "$DATE" --argjson end_time "$END_TIME" --arg end_time_formatted "$END_TIME_FORMATTED" --arg start_time_formatted "$START_TIME_FORMATTED" \
    '.[$topic].day = $day | .[$topic].total_time += $time | .[$topic].date = $date | .[$topic].end_times += [{"start_time": $start_time_formatted, "end_time": $end_time, "end_time_formatted": $end_time_formatted}] | .[$topic].end_times |= .[-5:]')

    TRACK_DATA=$(echo "$TRACK_DATA" | jq "del(.\"$TOPIC\".start_time)")

    echo "$TRACK_DATA" > "$TIME_TRACK_FILE"
    echo "Stopped tracking time for topic: $TOPIC on $DAY_OF_WEEK ($DATE). Time spent: $TIME_SPENT seconds. From $START_TIME_FORMATTED to $END_TIME_FORMATTED."
}

clear_tracking() {
    TOPIC="$1"
    if [[ -z "$TOPIC" ]]; then
        echo "Error: No topic provided to clear."
        return
    fi

    if [ -f "$TIME_TRACK_FILE" ]; then
        TRACK_DATA=$(cat "$TIME_TRACK_FILE")
    else
        echo "No tracking data found."
        return
    fi

    if echo "$TRACK_DATA" | jq -e ".\"$TOPIC\"" > /dev/null; then
        TRACK_DATA=$(echo "$TRACK_DATA" | jq "del(.\"$TOPIC\")")
        echo "$TRACK_DATA" > "$TIME_TRACK_FILE"
        echo "Cleared tracking data for topic: $TOPIC."
    else
        echo "Topic '$TOPIC' not found in tracking data."
    fi
}

clear_tracking() {
    TOPIC="$1"

    if [[ "$TOPIC" == "all" ]]; then
        echo "{}" > "$TIME_TRACK_FILE"
        echo "Cleared all tracking data."
        return
    fi

    if [[ -z "$TOPIC" ]]; then
        echo "Error: No topic provided to clear."
        return
    fi

    if [ -f "$TIME_TRACK_FILE" ]; then
        TRACK_DATA=$(cat "$TIME_TRACK_FILE")
    else
        echo "No tracking data found."
        return
    fi

    if echo "$TRACK_DATA" | jq -e ".\"$TOPIC\"" > /dev/null; then
        TRACK_DATA=$(echo "$TRACK_DATA" | jq "del(.\"$TOPIC\")")
        echo "$TRACK_DATA" > "$TIME_TRACK_FILE"
        echo "Cleared tracking data for topic: $TOPIC."
    else
        echo "Topic '$TOPIC' not found in tracking data."
    fi
}

visualize_time() {
    python3 "$VISUALIZER_SCRIPT"
}

case "$1" in
    start)
        start_tracking "$2"
        ;;
    stop)
        stop_tracking "$2"
        ;;
    clear)
        clear_tracking "$2"
        ;;
    clear-all)
        clear_tracking "all"
        ;;
    visual)
        python3 "$VISUALIZER_SCRIPT" "${2:-}"
        ;;
    *)
        echo "Usage: $0 {start|stop|clear [topic]|clear-all|visual} [topic]"
        ;;
esac
