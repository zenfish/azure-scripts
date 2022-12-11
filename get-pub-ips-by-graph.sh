#
# get subscription's public IP addrs, save it to a file w today's date, in both json and text
#
# Uses the 'az graph' command... takes no arguments
#
#
# Output is subscription + tab + public-ip-address... e.g.
# 
#   02211ac5-3fbc-4840-a121-1dc05125ac40    20.65.119.155
#   [...]
#
# Output is saved in various files in the "az.graph.query.public_ips.$TODAY.txt" form; for me, it's:
#
# az.graph.query.public_ips.2022-12-09.0.json       # first loop
# az.graph.query.public_ips.2022-12-09.1.json       # 2nd loop
# az.graph.query.public_ips.2022-12-09.2.json       # 3rd loop
# az.graph.query.public_ips.2022-12-09.3.json       # final loop
# az.graph.query.public_ips.2022-12-09.txt          # subs+ips
#

TODAY=$(date "+%Y-%m-%d")

#
# Graph can do things in chunks of 1000... try the first 1000
#
x=1000

# loop until done
for ((n=0;n<=100;n++)); do
    skippy=$(( $n * $x ))
    # echo $skippy
    az graph query --first $x --skip $skippy -q "Resources | where type contains 'publicIPAddresses' and isnotempty(properties.ipAddress)" > az.graph.query.public_ips.$TODAY.$n.json

    grep -q '  "data": \[\],' "az.graph.query.public_ips.$TODAY.$n.json"

    # count=$(jq '.count' "az.graph.query.public_ips.$TODAY.$n.json"

    if [ $? = 0 ]; then
        rm -f "az.graph.query.public_ips.$TODAY.$n.json"

        # in json and in txt
        jq -r '.data[] | .subscriptionId + "\t" + .properties.ipAddress' az.graph.query.public_ips.$TODAY.*.json > az.graph.query.public_ips.$TODAY.txt

        echo 'finis!'
        break
    fi

done

