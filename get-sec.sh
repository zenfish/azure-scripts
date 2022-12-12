#
# get subscription's security recommendations
#

if [ -z "$1" ]; then
    echo "Usage: $0 subscription-name"
    exit 1
fi

TODAY=$(date "+%Y-%m-%d")

subscription="$*"

base_url="https://management.azure.com"
api_version="?api-version=2015-06-01-preview"

# for securityStatuses
tokey="$HOME/.azure.token"

# if not within the last 10 mins
if [ ! -f "$tokey" ]; then
    az account get-access-token --query "{accessToken:accessToken}" -o tsv > "$tokey"
elif [ `gstat --format=%Y "$tokey"` -lt $(( `date +%s` - 1800 )) ]; then 
    az account get-access-token --query "{accessToken:accessToken}" -o tsv > "$tokey"
fi

# get solution
# https://$base_url/subscriptions/$sub/resourceGroups/$rg/microsoft.Security/securitySolutions/$solution?api-version={api-version}

# status
curl -s -X GET -H "Authorization: Bearer $(cat $tokey)" -H "Content-Type:application/json" $base_url/subscriptions/$subscription/providers/microsoft.Security/securityStatuses$api_version | json_pp > "$subscription.json"

