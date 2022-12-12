:
#
# usage: $0 subscription-name-or-ID
#
# List anonymous blobs or containers that may be anonymously enumerated 
# (and possibly containing more anon blobs, etc.) in a subscription.
#
# Listingh them takes a few calls -
#
#   get the storage accounts in a sub
#       list the containers/blobs for a storage account
#           check to see if they're anon
#

if [ -z "$1" ] ; then
    echo Usage: $0 subscription
    exit 1
fi

subscription="$*"

TODAY=$(date "+%Y-%m-%d")

tmp=$(mktemp)

# try to kill any leftovers
trap "rm -f $tmp" EXIT

#
# https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal
#
#### The storage account setting overrides the container setting.

#####   Public access is allowed for the storage account (default setting)
# ONLY if set to false is pub access is explicitly disallowed (null seems fine?)

# 
# get the storage accounts for a subscription
#
az storage account list --subscription "$subscription" |
    jq -r '.[] | select(.allowBlobPublicAccess!=false)| .name + "\t" + .id + "\t" + .primaryEndpoints.blob' | while read account aid endpoint ; do

    #
    # for each account possibly allowing... list the containers
    #
    az storage container list \
        --subscription "$subscription" \
        --account-name $account \
        --auth-mode login > $tmp

        #
        # for each container... do they allow anon?
        #
        jq -r '.[]| .name + "\t" + .properties.publicAccess' $tmp | while read cname access ; do

            if [ "$access" != "" ]; then
                if [ "$access" != "container" ] ; then
                    echo -e "$subscription\t$endpoint$cname\t$access" | tee -a $subscription.anon.txt
                #
                # can list things if a container
                #
                else
                    # echo -e "$subscription\t$endpoint$cname\t$access"
                    # https://<storage-account-name>.blob.core.windows.net/<container-name>?restype=container&comp=list
                    echo -e "$subscription\t$endpoint$cname?restype=container&comp=list\t$access" | tee -a $subscription.anon.txt
                fi
            fi

    done

done

