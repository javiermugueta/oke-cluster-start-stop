# oke-cluster-start-stop
A kubectl extension plugin

## purpose
Starts or stops all the compute nodes of an OKE cluster<p>
16/dec/2019: updated with script for stand alone use
## notes
Unlike standard oci CLI commands, we use pretty names and the tool  
seeks for the internal ocids for you.  

The first time you use the tool, or when the session gets invalidated,  
an "oci session authenticate" command is launched and a  
new browser window pops up for you to log in with  
appropriate credentials in Oracle Cloud.  

...  
Session was deemed invalid by service  
    Please switch to newly opened browser window to log in!  
    Completed browser authentication process!  
...  

![Click on Continue](https://github.com/javiermugueta/oke-cluster-start-stop/blob/master/a.jpg)
<br>
![Sign in](https://github.com/javiermugueta/oke-cluster-start-stop/blob/master/c.jpg)
<br>
![Close the browser tab when done](https://github.com/javiermugueta/oke-cluster-start-stop/blob/master/b.jpg)
<br>
At any time you can terminate the session issuing the following  
```
oci session terminate --profile okecmd --auth security_token
```
...or just let the session expire as time goes by.  

NOTE: Don't forget to end the session if you want to change from one cloud account (tenant) to a different one!!!  
NOTE: Remember to change the tennant clicking in the [Change tenant] link in the Sing In page
## installation 
### prereqs
#### oci cli
https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm
#### kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl/
#### jq
##### jq on mac
brew install jq
##### jq on linux
sudo yum install jq
#### krew
https://github.com/kubernetes-sigs/krew <br>
### install plugin
#### from krew-index (not yet available, pending on approvals)
```
kubectl krew install oke-cluster-start-stop
```
#### locally
```
git clone https://github.com/javiermugueta/oke-cluster-start-stop.git
cd oke-cluster-start-stop
kubectl krew install --manifest=oke-cluster-start-stop.yaml --archive=oke-cluster-start-stop-1.0.0.zip
```
### cloud account
If you don't have an OCI account grab for a free one here: https://myservices.us.oraclecloud.com/mycloud/signup?language=en&sourceType=:ow:o:p:nav:0912BCButton  

## remove plugin
```
kubectl krew remove okecmd
```
## try it!
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
### verify the tool with your existing cluster(example)
```
kubectl oke-cluster-start-stop -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=STOP
```

### example output
```
javiermugueta:oke-cluster-start-stop javiermugueta$ kubectl oke-cluster-start-stop -r=eu-frankfurt-1 -c=brazaletes -k=cluster2 -o=STOP

region          = eu-frankfurt-1
compartment     = brazaletes
k8scluster      = cluster2
operation       = STOP

Session is valid until 2019-09-17 14:51:51

Compartment brazaletes found!
Cluster cluster2 found!
Proceeding with pool "pool1"
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljspabpo3eh3ats47uahjjr2xoikrzubsggawbnfzarxpufhr2mzyia
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljrzjjdoor5pyw3q466x77rx3icrh6inlotvufkbxveiar62lbmxn6q
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljtm24kx2ptaxaylybhahnx4kvax3una5vr2o5ei7mbz7fowvbtfppa
Cluster cluster2 found!
Proceeding with pool "polo4"
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljssh2ek5cyb3fzsah6fgep5khs7vjvch2qmjnszcy4eekqha766cyq
      STOPing node ocid1.instance.oc1.eu-frankfurt-1.abtheljtnar4qx3yhqhdqxgrxzfis47sfnlo2xvpbmgh564f7nk4lzt3gbdq
Done, have a good day!
```
