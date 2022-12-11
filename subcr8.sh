
#
# get subscription creation time (+metadata for various sub elements, though I through that all away)
#
# Usage: $0 subscription-ID      # !!! not name, the 36 char sub ID
#
# requires azure cli, curl, and jq
#
# This needs an azure token... this tries to get that via 'az account get-access-token'... 

if [ -z "$1" ]; then
    echo "Usage: $0 subscription-ID             # <- ID, not Name!"
    exit 1
fi

subscription="$1"

if [[ ! "$subscription" =~ [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} ]]; then
    echo -e 'This requirees a subscription ID!  36 chars, looks something like:\n'
    echo -e "\t7f50be07-41f8-4202-b3c9-489394f26a1f"
    echo ""
    exit 2
fi

# for securityStatuses
beary="$HOME/.azure.token"

# if not within the last 10 mins
if [ ! -s "$beary" -o `gstat --format=%Y "$beary"` -lt $(( `date +%s` - 1800 )) ]; then
    az account get-access-token --query "{accessToken:accessToken}" -o tsv > "$beary"
    if [ $? != 0 ]; then
        echo "Error getting access token [$?], bailin'"
        exit 3
    fi
fi

URL="https://management.azure.com/subscriptions/$subscription/resources?api-version=2020-06-01&%24expand=createdTime&%24select=name%2CcreatedTime"

# try to get the oldestcreatedTime
curl -s \
    -H "'Accept-Encoding': 'gzip, deflate'"     \
    -H "'Accept': '*/*'"    \
    -H "'Connection': 'keep-alive'"     \
    -H "'CommandName': 'rest'"  \
    -H "'ParameterSetName': '--url --url-parameters'"   \
    -H "Authorization: Bearer $(cat $beary)"    \
    "$URL" | jq -r '.value[].createdTime' | sort -n |head -1
    

