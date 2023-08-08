# BreatheHR Holiday pre-approval

Automatically create '''and approve''' holiday for members of staff in BreatheHR.

We use this to automatically book off public holidays for our staff.

Usage:  `preapprove-holiday.sh <holiday_file>`

`<holiday_file>`: A pipe delimited file of dates and decriptions in the format...
```
2024-01-01|New Year’s Day
2024-03-29|Good Friday
```

Configuration:  The following variables should be set in a settings.conf file in the same directory
* `PRODUCTION=`    # If set to "TRUE" then the script will use the production API
* `SAND_API=`      # API Key for the Sandbox enviroment
* `PROD_API=`      # API Key for the Production enviroment

### Requirements
Requires `curl`, `date` & `jq`

### Bugs
* This script breaks at over 100 users :-p

