#!/bin/bash

# Check if file path is provided
if [ -z "$1" ]; then
    echo "Usage: send_to_phone <file_path>"
    exit 1
fi

# Check if ADB device is connected
if ! adb devices | grep -q "device$"; then
    echo "ADB device not connected. Run 'adb connect <PHONE_IP>:5555' first."
    exit 1
fi

# Define the destination directory on Android's internal storage
DEST_DIR="/storage/emulated/0/Downloads"

# Transfer file to Android device's Downloads folder
adb push "$1" "$DEST_DIR"

# Check if the file was transferred successfully
if [ $? -eq 0 ]; then
    echo "File '$1' transferred successfully to '$DEST_DIR' on Android."
else
    echo "File transfer failed."
fi

