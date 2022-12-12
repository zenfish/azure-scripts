# azure-scripts

Some small scripts I'm using on azure for various tasks; these are for a mac, should
be relatively (sic) version independent... (famous last words.)

Scripts require various things... I think with something like -

    brew install azure-cli jq core-utils

(The cost one uses the gdate program in the GNU core-utils) you should be good. 

# scripts

So, the shell scripts. I've got a few kazillion of these, but thought
I'd start with a few...  I actually wouldn't mind using powershell,
but it blows on the mac still (haven't tried it on linux), so I tend to
use azure's cli; these work pretty reliably for me, at least.

If you have a lot of subscriptions (I've over 1000), I'll typically do
something like (on a mac/linux, with AZ CLI installed - e.g. `brew install
azure-cli`, etc), leveraging the wonderful `rush` run-things-in-parallel
shell tool (https://github.com/shenwei356/rush)

    # get all subs in tenant
    az account list --query "[].{id:id,name:name}" -o tsv > subs.txt

    #
    # run one of the below, 50 at a time
    #

    (cat subs.txt | rush --verbose --jobs 50 './get-containers-sub.sh {1}') | tee -a sub-containers.txt

Script names and what they do -

    subcr8.sh                   azure keeps metadata... you can get create time, modification time... not 
                                quite mactimes, but hey

    get-containers-sub.sh       dump the containers found in a subscription
    get-dock-images-sub.sh      dump the docker images if a sub has any readable ACR registries
    get-pub-ips.sh              get public IPs in a subscription

    get-pub-ips-by-graph.sh     get all the ips in your tenant by the weird "az graph query"... it's only 
                                really weird when you start querying a LOT of subscriptions or get tons of 
                                results, then you have to jump through some hoops. But it can be very fast.

    get-costs-N.sh              This TAKES FOREVER. It uses "az consumption usage", which sez 
                                "WARNING: Command group 'consumption' is in preview and under development" -
                                for years now.  I filed bugs, they've been ignored.

                                Don't even try to parallelize this beyond like... 2 or 3... it'll die. What a dog.

                                # NOTE: uses the gdate program in the GNU core-utils (brew install core-utils)

    get-sec.sh                  Even w/o cloud defender or w/e Azure is peddling, they run various security
                                checks on an ongoing basis against your systems/setup/confs along with their
                                ratings and severity. This gets those for a subscription.

