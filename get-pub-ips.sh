#
# get subscription's public IP addrs
#
# Usage: $0 sub-name-or-ID
#
if [ -z "$1" ]; then
    echo "Usage: $0 subscription-name"
    exit 1
fi

echo $*

az network public-ip list --subscription "$*" -o tsv --query "[].{Address: ipAddress}"

echo
