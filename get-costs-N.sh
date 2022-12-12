
#
# get costs for a sub for the last N months
#
# uses the date program in the GNU core-utils
#

if [ -z "$2" ]; then
    echo "Usage: $0 subscription-name N-months"
    exit 1
fi

set -e

Y_M=$(date "+%Y-%m")

subscription="$1"

N="$2"

out="costs.$Y_M.$N"mo

# N months ago
start=$(gdate -d "$N months ago" "+%Y-%m-01")

# EOM last month... this month first day - 1
end=$(gdate -d "$(date +%Y/%m/01) - 1 day 00:00" +"%Y-%m-%d")

date_filter="-s $start -e $end"

date_filter="-s 2022-04-13 -e 2022-04-20"

echo getting subscription $subscription costs...

#
#  XXXXXXXXXX   Sigh. This is in preview and takes FOREVER. I filed bugs, they've been ignored.
#
az consumption usage list -a -m $date_filter --subscription "$subscription" > "$out.$subscription.json"

