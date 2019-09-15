# oke-cluster-start-stop
A kubectl extension plugin

## purpose
Starts or stops all the compute nodes of an OKE cluster
## notes
The first time you use the tool or when the session gets invalidated,  
the tool issues on behalf you an "oci session authenticate"  
command that opens up a browser for you to log in you cloud account.
...  
Session was deemed invalid by service  
    Please switch to newly opened browser window to log in!  
    Completed browser authentication process!  
...  
![Click on Continue](https://github.com/javiermugueta/okecmd/blob/master/a.jpg)
<br>
![Sign in](https://github.com/javiermugueta/okecmd/blob/master/c.jpg)
<br>
![Close the browser tab when done](https://github.com/javiermugueta/okecmd/blob/master/b.jpg)
<br>
At any time you can terminate the session issuing the following
```
oci session terminate --profile okecmd --auth security_token
```
## installation 
### prereqs
#### oci cli
https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm
#### kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos
#### homebrew
https://brew.sh
#### krew
https://github.com/kubernetes-sigs/krew <br>
## install
### from krew-index
```
kubectl krew install oke-cluster-start-stop
```
### locally
```
git clone https://github.com/javiermugueta/oke-cluster-start-stop.git
cd oke-cluster-start-stop
kubectl krew install --manifest=oke-cluster-start-stop.yaml --archive=oke-cluster-start-stop-1.0.0.zip
```

## remove
```
kubectl krew remove okecmd
```
## verify
### list of plugins installed
```
(⎈ |mhifra:sample-coherence-ns)MacBook-Pro:oke-cluster-start-stop javiermugueta$ **kubectl krew list**
PLUGIN                 VERSION
access-matrix          7a16c61dfc4e2924fdedc894d59db7820bc4643a58d9a853c4eb83eadd4deee8
krew                   dc2f2e1ec8a0acb6f3e23580d4a8b38c44823e948c40342e13ff6e8e12edb15a
**oke-cluster-start-stop 72b48eebd1b7bc71eca2573274d4ef7b7fb91e6806d873ba815e12a880741a68**
okecmd                 72b48eebd1b7bc71eca2573274d4ef7b7fb91e6806d873ba815e12a880741a68
rbac-view              2a3a6cca926bfa2c4116b76f376047946f4188f7f2129ac3c5cb9fe29b7c176d
resource-capacity      685c964d0416c23f70b75fdd73fdda5a32f4331125892a9415977f8dd3553050
view-utilization       ae96c8c2234ae7e66936c6c4c7c1260f1c51d46cfa3b836c49cfd3ab991d93f8
```
### verify the tool with your existing cluster(exampke)
```
kubectl okecmd -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=STOP
```

### example output
```
(⎈ |mhifra:sample-coherence-ns)MacBook-Pro:oke-cluster-start-stop javiermugueta$ kubectl oke-cluster-start-stop -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=STOP

      Usage: kubectl oke-cluster-start-stop -r=[region] -c=[compartment name] -k=[k8s cluster] -o=[START|STOP]
      -r=[region], one of {ca-toronto-1, eu-frankfurt-1, uk-london-1, us-ashburn-1, us-gov-ashburn-1, us-gov-chicago-1, us-gov-phoenix-1, us-langley-1, us-luke-1, us-phoenix-1}
      -o=[START|STOP]
      -k=[name (case sensitive) of the k8s cluster]
      -c=[compartment name (case sensitive) of the compartment the cluster belongs to]
      Example: kubectl oke-cluster-start-stop -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=START

region          = eu-frankfurt-1
compartment     = brazaletes
k8scluster      = cluster2
operation       = STOP

Session was deemed invalid by service
    Please switch to newly opened browser window to log in!
    Completed browser authentication process!
Enter the name of the profile you would like to create: Config written to: /Users/javiermugueta/.oci/config

    Try out your newly created session credentials with the following example command:

    oci iam region list --config-file /Users/javiermugueta/.oci/config --profile okecmd --auth security_token

Proceeding with pool "pool1" of cluster ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaaftgeobqga3ggnjrgq2tknrqgjswimbvmrtdombugc3wmmzwhezt
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljspabpo3eh3ats47uahjjr2xoikrzubsggawbnfzarxpufhr2mzyia
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljrzjjdoor5pyw3q466x77rx3icrh6inlotvufkbxveiar62lbmxn6q
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljtm24kx2ptaxaylybhahnx4kvax3una5vr2o5ei7mbz7fowvbtfppa
Proceeding with pool "polo4" of cluster ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaaftgeobqga3ggnjrgq2tknrqgjswimbvmrtdombugc3wmmzwhezt
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljssh2ek5cyb3fzsah6fgep5khs7vjvch2qmjnszcy4eekqha766cyq
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljtnar4qx3yhqhdqxgrxzfis47sfnlo2xvpbmgh564f7nk4lzt3gbdq
Done, have a good day!
```