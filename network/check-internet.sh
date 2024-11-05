#!/bin/bash

# Expanded list of reliable websites to test connectivity
DEFAULT_WEBSITES=(
  "google.com" "cloudflare.com" "openai.com" "github.com" "wikipedia.org"
  "microsoft.com" "apple.com" "amazon.com" "facebook.com" "twitter.com"
  "linkedin.com" "yahoo.com" "bbc.com" "cnn.com"
  "nytimes.com" "reddit.com" "instagram.com" "whatsapp.com" "stackoverflow.com"
  "bing.com" "duckduckgo.com" "espn.com" "ebay.com"
)
TIMEOUT=2  # Timeout in seconds
RUN_SPEEDTEST=false

# Colors for output styling
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to check connectivity to a single site
check_site() {
  local site="$1"
  if ping -q -c 1 -W $TIMEOUT "$site" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ $site is reachable.${RESET}"
    return 0
  else
    echo -e "${RED}❌ $site is unreachable.${RESET}"
    return 1
  fi
}

# Function to check multiple sites and stop if any site is reachable
check_internet() {
  local websites=("${@:-${DEFAULT_WEBSITES[@]}}")
  local success_count=0
  local total_sites=${#websites[@]}

  echo -e "${YELLOW}Checking internet connection...${RESET}"
  echo "------------------------------------"
  for site in "${websites[@]}"; do
    if check_site "$site"; then
      success_count=$((success_count + 1))
      break  # Exit the loop if a site is reachable
    fi
  done
  echo "------------------------------------"

  # Summary
  if [ "$success_count" -gt 0 ]; then
    echo -e "${GREEN}🌐 Internet connection is active. (1/${total_sites} sites reachable)${RESET}"
    return 0
  else
    echo -e "${RED}🚫 No internet connection detected. (0/${total_sites} sites reachable)${RESET}"
    return 1
  fi
}

# Main script logic to parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -s|--speedtest)
      RUN_SPEEDTEST=true
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-s|--speedtest]"
      exit 1
      ;;
  esac
  shift
done

# Run the internet check
check_internet
CHECK_RESULT=$?

# Run speed test if requested and if connectivity check passed
if [ "$RUN_SPEEDTEST" = true ] && [ "$CHECK_RESULT" -eq 0 ]; then
  echo -e "${YELLOW}Running speed test...${RESET}"
  speedtest
fi

exit $CHECK_RESULT

