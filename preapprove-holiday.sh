#!/usr/bin/env bash
#
# Description:  Automatically create and approve holiday for members of staff in BreathHR
#
# Usage:  $0 <holiday_file>
#
#         <holiday_file>: A pipe delimited file of dates and decriptions in the format...
#             2024-01-01|New Year’s Day
#             2024-03-29|Good Friday
# 
# Configuration:  The following variables can be set in a settings.conf file in the same directory
#     PRODUCTION=    # If set to "True" then the script will use the production API
#     SAND_API=      # API Key for the Sandbox enviroment
#     PROD_API=      # API Key for the Production enviroment
#

set -e
set -u

# Basic check that we have the tools that all systems should have (uses set -e)
# echo, cd, pwd are all bash built-in's
hash dirname
#hash crontab
#hash mktemp
#hash find
#hash mail # not used here but worth checking as the EMAILSCRIPT script uses it
#hash head
#hash tail
#hash cat
#hash git
#hash sed

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#FILESDIR="$SCRIPTDIR/archive"
#EMAILSCRIPT="$SCRIPTDIR/create-ticket.sh"
#REPOSCRIPT="$SCRIPTDIR/check-repo.sh"
#LOCALHASH=$(git -C "${SCRIPTDIR}" rev-parse @) # @ is a shortcut for HEAD

#TEMPFILE=$(mktemp)

# header

# https://www.gov.uk/bank-holidays
# https://developer.breathehr.com/


# set some vars

#check for jq

# get working dir
# source config
# are we sandbox or prod?
#


#print input file

# print users

# ask for user

#request and approve for each date

#curl -Ss "https://api.breathehr.com/v1/employees?page=1&per_page=100" -H "X-API-KEY: $PROD_API" | jq -r ".employees[] | [.id, .first_name, .last_name, .status] | @csv

#curl -Ss "https://api.breathehr.com/v1/employees/1287460/leave_requests?page=1&per_page=100" -H "X-API-KEY: $PROD_API" -d id=1287460 -d leave_request[start_date]=2023-01-02 -d leave_request[end_date]=2023-01-02 -d "leave_request[type]=Holiday" -d "leave_request[notes]=Public Holiday" -d "leave_request[half_start]=false" | jq


