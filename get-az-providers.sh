#
# Usage: $0 provider-namespace
#
#   E.g. $0 Microsoft.Storage
#
# In Azure's provider web, Get the most recent operations supported by the provider 
# namespace given on the command line.
#
# This uses the "curl" command to grab information from Azure... to get the data it seems
# I need a token, which I try to get. There may well be a way to get this info from:
#
#   az provider show --namespace Microsoft.Storage
#
# (Which I do in a backhanded way), but... you do need to dig up the right API version
# to query with, which is why I'm jumping through hoops here.
#
#   Requires:
#
#     MS's "az" cli interface
#     jq    # https://stedolan.github.io/jq/    on a mac, "brew jq" will install
#
# You can use something like "az provider list/show" to look at providers for
# a given subscription, but this shows details on providers that you may or
# may not be using. More on all this stuff can be found here and other places -
# 
#   https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types
#

# die on errz
set -e

# need a provider name
if [ -z "$1" ]; then
    echo "Usage: $0 provider"
    exit 2
fi
provider="$1"

# need the azure CLI
if [ -z $(which az) ]; then
    echo "Need the Azure CLI command (az) to run... bailing out...."
    exit 3
fi

# use json_pp if in path to pretty format
pretty="cat"
if [ ! -z $(which json_pp) ]; then
    pretty="json_pp"
fi


# how long before token refresh
MAX_TIME=10 # in mins

#
# will end up something like:
#
#   https://management.azure.com/providers/Microsoft.Storage/operations?api-version=2017-10-01
#
base_url="https://management.azure.com"
# this will be wrong... used to bait azure so they'll send ones that work
api_version="?api-version=XXX"

# try to get a token to access
az_token="$HOME/.azure.token"

# if not within the last 10 mins
if [ ! -s "$az_token" -o -z "$(find "$az_token" -mmin "$MAX_TIME")" ]; then
    az account get-access-token --query "{accessToken:accessToken}" -o tsv > "$az_token"
fi

#
# give it a shot
#
# curl -s -X GET -H "Authorization: Bearer $(cat $az_token)" -H "Content-Type:application/json" $base_url/providers/$provider/operations$api_version | $pretty

echo hunting for a good api for provider $provider > /dev/stderr
# pass a bad API version, hopefully get a good one back
good_api="?api-version="$(curl -s -X GET -H "Authorization: Bearer $(cat $az_token)" -H "Content-Type:application/json" $base_url/providers/$provider$api_version | $pretty | grep "The api-version 'XXX' is invalid"  | awk -F, '{print $1}' | sed "s/^.*\'//")

#
# try to find the operations bit
#
echo now looking... does it have an operations bit? > /dev/stderr
op_api="?api-version="$(curl -s -X GET -H "Authorization: Bearer $(cat $az_token)" -H "Content-Type:application/json" $base_url/providers/$provider$good_api | jq -r '.resourceTypes[] | (select(.resourceType=="operations") | .apiVersions[0])')

#
# and... finally... get the data we want
#
echo ok... if all else worked... try to get the actual operations supported by the provider > /dev/stderr
curl -s -X GET -H "Authorization: Bearer $(cat $az_token)" -H "Content-Type:application/json" $base_url/providers/$provider/operations$op_api | $pretty

