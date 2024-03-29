#!/bin/bash
# 1.0.0     javier.mugueta      15-dic-2019   new
# 1.0.1     javier.mugueta      29-mar-2020   bug resolved, script was not honoring the region parameter  
# 1.0.2     javier.mugueta      09-mar-2023   get compartment ocid from pretty name in a single line of code
# 1.0.3     javier.mugueta      12-mar-2023   get cluster ocid from pretty name in a single line of code
#
# Copyright (c) 2019 javier mugueta
#
# The Universal Permissive License (UPL), Version 1.0
#
# Subject to the condition set forth below, permission is hereby granted to any
# person obtaining a copy of this software, associated documentation and/or data
# (collectively the "Software"), free of charge and under any and all copyright
# rights in the Software, and any and all patent rights owned or freely
# licensable by each licensor hereunder covering either (i) the unmodified
# Software as contributed to or provided by such licensor, or (ii) the Larger
# Works (as defined below), to deal in both
#
# (a) the Software, and
# (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if
# one is included with the Software (each a "Larger Work" to which the Software
# is contributed by such licensors),
#
# without restriction, including without limitation the rights to copy, create
# derivative works of, display, perform, and distribute the Software and make,
# use, sell, offer for sale, import, export, have made, and have sold the
# Software and the Larger Work(s), and to sublicense the foregoing rights on
# either these or other terms.
#
# This license is subject to the following condition:
# The above copyright notice and either this complete permission notice or at
# a minimum a reference to the UPL must be included in all copies or
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 
#
usage(){
    echo "Usage:"
    echo "      kubectl oke-cluster-start-stop -r=[region] -c=[compartment name] -k=[k8s cluster] -o=[START|STOP]"
    echo "      -r=[region], one of {ca-toronto-1, eu-frankfurt-1, uk-london-1, us-ashburn-1, us-gov-ashburn-1, us-gov-chicago-1, us-gov-phoenix-1, us-langley-1, us-luke-1, us-phoenix-1, after 3+ years more regions available now ...}"
    echo "      -o=[START|STOP]"
    echo "      -k=[name (case sensitive) of the k8s cluster]"
    echo "      -c=[compartment name (case sensitive) of the compartment the cluster belongs to]"
    echo "      Example: kubectl oke-cluster-start-stop -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=START"
}
#
# for mac, if jq not installed do it (homebrew needed), for other platfforms jq is a prerequisite see documentation
(brew list jq || brew install jq) >/dev/null 2>&1
#
MAX_WAIT_TIME=120
#
if [[ "$#" -ne 4 ]]; then
    echo
    echo "Wrong number of arguments passed!"
    echo
    usage
    exit
fi
for i in "$@"
do
case $i in
    -o=*)
    COMMAND="${i#*=}"
    shift
    ;;
    -r=*)
    REGION="${i#*=}"
    shift
    ;;
    -c=*)
    COMPARTMENT="${i#*=}"
    shift
    ;;
    -k=*)
    CLUSTER="${i#*=}"
    shift
    ;;
    *)
          usage
          exit
    ;;
esac
done
#
if [[ $COMMAND == "START" ]]
    then
        WAITSTATE="RUNNING"
elif [[ $COMMAND == "STOP" ]]
    then
        WAITSTATE="STOPPED"
fi
#
#usage
#
echo ""
echo "region          = ${REGION}"
echo "compartment     = ${COMPARTMENT}"
echo "k8scluster      = ${CLUSTER}"
echo "operation       = ${COMMAND}"
echo ""
#
#
# get compartment ocid from pretty name
compartment_id=$(oci iam compartment list --compartment-id-in-subtree true --all | jq --arg compname "$COMPARTMENT" '.data[] | select(."name"==$compname)' | jq -r ."id")

echo "Compartment ocid: "$compartment_id

# get cluster ocid
CLUSTER_ID=$(oci ce cluster list --compartment-id $compartment_id --region $REGION | jq --arg clustername "$CLUSTER" '.data[] | select(."name"==$clustername)' | jq -r ."id")
echo "Cluster ocid: "$CLUSTER_ID

# get list of nodepools
nodepoolinfo=`oci ce node-pool list --compartment-id $compartment_id --region $REGION`
nodepoolinfo="${nodepoolinfo//cluster-id/cluster_id}"
count=`echo $nodepoolinfo | jq '.data | length'`
count=`expr $count - 1`
for i in $(eval echo {0..$count})
do
    id=`echo $nodepoolinfo | jq .data[$i].id`
    id=$(eval echo $id)
    name=`echo $nodepoolinfo | jq .data[$i].name`
    cluster=`echo $nodepoolinfo | jq .data[$i].cluster_id`
    cluster=$(eval echo $cluster)
    # which nodepools belong to my cluster?
    if [[ $CLUSTER_ID == $cluster ]]
    then
        echo "Cluster $CLUSTER found!"
        # get the compute nodes of each pool
        data=`oci ce node-pool get --node-pool-id $id --region $REGION`
        count=`echo $data | jq '.data.nodes | length'`
        count=`expr $count - 1`
        nodes=`echo $data | jq .data.nodes`
        echo "Proceeding with pool $name"
        for i in $(eval echo {0..$count})
        do
            nodeid=`echo $nodes | jq .[$i].id`
            nodeid=$(eval echo $nodeid)
            cmd="oci compute instance action --action $COMMAND --instance-id $nodeid --region $REGION"
            echo "      ${COMMAND}ing node $nodeid"
            # issue command
            ($cmd >/dev/null 2>&1)
            #$cmd
        done
    fi
done
echo "Done, have a good day!"
exit