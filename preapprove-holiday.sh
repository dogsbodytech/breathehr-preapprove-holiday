#!/usr/bin/env bash
#
# Description:  Automatically create and approve holiday for members of staff in BreatheHR
#
# Usage:  $0 <holiday_file>
#
#         <holiday_file>: A pipe delimited file of dates and decriptions in the format...
#             2024-01-01|New Year’s Day
#             2024-03-29|Good Friday
# 
# Configuration:  The following variables can be set in a settings.conf file in the same directory
#     PRODUCTION=    # If set to "TRUE" then the script will use the production API
#     SAND_API=      # API Key for the Sandbox enviroment
#     PROD_API=      # API Key for the Production enviroment
#
# Notes: This script breaks at over 100 users :-p 
#        Grab UK Public Holidays from https://www.gov.uk/bank-holidays
#        BreatheHR API docs can be found at https://developer.breathehr.com/
#

set -e
set -u

# Basic check that we have the tools that all systems should have (uses set -e)
# echo, cd, pwd are all bash built-in's
hash dirname
hash curl
hash date
hash jq || (echo "Missing the jq command-line JSON processor"; exit)

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$SCRIPTDIR/settings.conf" || (echo "Missing $SCRIPTDIR/settings.conf"; exit)

if [ $# -eq 0 ]; then
  echo "Error: No Holiday faile specified as \$1"
  echo "  Usage:  $0 <holiday_file>"
  exit
fi

DATESFILE="$1"
if [[ ! -r ${DATESFILE} ]];then
  echo "Error: Can't read $DATESFILE"
  exit
fi

if [ "$PRODUCTION" = "TRUE" ];then
  URL="https://api.breathehr.com"
  KEY="$PROD_API"
else
  URL="https://api.sandbox.breathehr.info"
  KEY="$SAND_API"
fi
PARAMS="page=1&per_page=100"

echo
echo "We will be importing the following dates"
echo "========================================"
while IFS='|' read -ra LINE; do
    DATE=$(date --date="${LINE[0]}" "+%d %b %Y") # Check and sanitise the date
    echo "${DATE} - ${LINE[1]}"
done < "$DATESFILE"

echo
#read -r -p "Does this look OK? Really?? [y/n] " CHECKOK
#if [[ "$CHECKOK" =~ ^([yY][eE][sS]|[yY])$ ]]; then
#  echo
#else
#  exit 1
#fi

echo -e "UID\tName\t\tStatus"
echo -e "===\t====\t\t======"
curl -Ss "${URL}/v1/employees?${PARAMS}" -H "X-API-KEY: ${KEY}" | jq -r '.employees[] | [.id, (.first_name + " " + .last_name), .status] | @tsv'

read -r -p "Enter a valid employee UID: " EMPLOYEE
CHECK=$(curl -Ss "${URL}/v1/employees/$EMPLOYEE?${PARAMS}" -H "X-API-KEY: ${KEY}" | jq -r 'try .employees[] | .id')
if [[ "$EMPLOYEE" = "$CHECK" ]]; then
  echo
else
  echo 
  echo "Error: \"$EMPLOYEE\" is not a valid employee UID"
  exit 1
fi

while IFS='|' read -ra LINE; do
  DATE=$(date --date="${LINE[0]}" -I)
  DESC="${LINE[1]}"
  echo "Requesting: ${DATE} - $DESC"
  LEAVEID=$(curl -Ss "${URL}/v1/employees/$EMPLOYEE/leave_requests?${PARAMS}" -H "X-API-KEY: $KEY" -d "id=$EMPLOYEE" -d "leave_request[start_date]=$DATE" -d "leave_request[end_date]=$DATE" -d "leave_request[type]=Holiday" -d "leave_request[notes]=$DESC" -d "leave_request[half_start]=false" | jq -r 'try .leave_requests[] | .id')
  sleep 1
  if [[ "$LEAVEID" == "null" ]]; then
    echo "  WARNING: Request Failed check something else isn't already booked"
  else
    echo -n "  Approving request..."
    OUTPUT=$(curl -Ss "${URL}/v1/leave_requests/$LEAVEID/approve?${PARAMS}" -H "X-API-KEY: $KEY" -d "id=$LEAVEID" | jq -r 'try .absences[] | .id')
    echo "  done"
    sleep 1
  fi
echo 
done < "$DATESFILE"

