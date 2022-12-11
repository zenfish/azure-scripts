:
#
# usage: $0 subscription
#
# gets the images+tags of all things in an ACR registry
#
set -e
# set -x

if [ -z "$1" ] ; then
    echo Usage: $0 subscription
    exit 1
fi
subscription="$1"

#
# list the registries in the subscription
#
az acr list --subscription "$subscription" --query "[].{Name:name}" -o tsv | while read registry; do
    #
    # get ready.. login to each reg to be safe
    #
    az acr login -n "$registry" --subscription "$subscription" &> /dev/null

    #
    # list the repos in each reg
    #
    az acr repository list --subscription "$subscription" -n "$registry" | jq -r ' .[]' | while read repository ; do
        echo -n -e "$subscription\t$registry\t$repository\t";
        az acr repository show-tags --subscription "$subscription" -n "$registry" --repository "$repository" --orderby time_desc --top 1 | jq -r ".[]"
    done
done

