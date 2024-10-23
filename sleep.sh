#!/bin/bash

# Get the current time in seconds since the epoch
current_time=$(date +%s)
current_hour=$(date +%H)
current_minute=$(date +%M)

# Define default target time (7:20 AM)
default_hour=7
default_minute=20

# Assign input parameters or default values
target_hour=${1:-$default_hour}
target_minute=${2:-$default_minute}

# Calculate the target time in seconds since the epoch
target_time=$(date -d "today $target_hour:$target_minute" +%s)

# If the target time has already passed today, calculate for tomorrow
if [ $current_time -gt $target_time ]; then
    target_time=$(date -d "tomorrow $target_hour:$target_minute" +%s)
fi

# Calculate the difference in seconds
time_difference=$((target_time - current_time))

# Convert seconds to hours and minutes
hours_until_target=$((time_difference / 3600))
minutes_until_target=$(((time_difference % 3600) / 60))

# Output the result
echo "Time left until $target_hour:$target_minute AM: $hours_until_target hours and $minutes_until_target minutes"

# Evaluate sleep quality based on how many hours until the target time
if [ $hours_until_target -ge 9 ]; then
    echo "Sleep Quality: Excellent sleep schedule"
elif [ $hours_until_target -ge 8 ] && [ $hours_until_target -lt 9 ]; then
    echo "Sleep Quality: Good sleep schedule"
elif [ $hours_until_target -ge 7 ] && [ $hours_until_target -lt 8 ]; then
    echo "Sleep Quality: Moderate sleep"
else
    echo "Sleep Quality: Bad sleep"
fi

