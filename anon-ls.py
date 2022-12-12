#!/usr/bin/env python3
#
#   Usage: $0 container-uri
#
# URI should look something like -
#
#   https://zenfishy.blob.core.windows.net/flounder
#
#  You can run this over the output of get-anon-blobs.sh
#
# list directories/blobs in an azure storage container in
# a somewhat "ls" like mode.
#
# if it's anonymous blob, it'll output the size and that path name, like:
#
#    205102	    foo/bar/file.txt
#
# Or, if the first three letters of a line are "[d]" - then the line 
# refers to a directory which may hold additional directories and/or 
# blobs - e.g. -
#
#   [d]     /foo/
#   [d]     /foob/bar/
#
# etc.
#
# The path of blobs discovered with this tool can be appended to 
# the base URI (e.g. the argument passwed to the script) and viewed 
# via curl/browser/whatever w/o authentication
#

from azure.storage.blob import ContainerClient
from azure.storage.blob import BlobServiceClient

import os
import sys

if len(sys.argv) == 2:
    uri = sys.argv[1]
else:
    print("Usage: %s container-uri" % sys.argv[0])
    sys.exit(1)

# 
# from something like - https://zenfishy.blob.core.windows.net/flounder
#

url       = uri.split("/")[2]
container = uri.split("/")[3]

# strip off this if at the end of the container string
n = container.find('?restype=container&comp=list')
if n > 1:
    container = container[0:container.find('?restype=container&comp=list')]

bsc       = BlobServiceClient(account_url=url)
bclient   = bsc.get_container_client(container)

blobbies = []

def take_a_stroll(c, dur):

    blobs = c.walk_blobs(name_starts_with=dur)

    # print(blobs)

    for blob in blobs: 

        # -rw-------
        # drwx------
        try:
            print("%10d\t%s" % (blob.size, blob.name))
        except:
            print("[d]" + " " * 7 + "\t%s" % (blob.name))
            pass

        # if blob.size:
        #     print("%10d\t%s" % (blob.size, blob.name))
        # print(blob.name)

        blobbies.append(blob)

        if (blob.name[-1] == "/" and blob.name not in blobbies):
            take_a_stroll(c, blob.name)

        # print("")

    return blobbies

blobs = take_a_stroll(bclient, "/")

