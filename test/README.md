# Using the test suite 

This test suite can be used after setting up several things. 

* Libvirt must be installed in order to spin up VMs.
* KVM acceleration must be enabled to be used with libvirt. You can check if KVM is enabled by running `kvm-ok` in a terminal. Be aware that kvm will usually only be enabled on the architecture your own CPU is running on. If you use an x86_64 CPU, you will not be able to run AArch64 VMs with KVM.
* Adding a trust zone to your firewall which encompasses the IP adresses you will be working with. This is necessary as Matchbox and PXE can get stuck because of it.
* Adding the nodes you will be deploying's domain names and IPs to your known hosts. Typhoon needs to know FQDNs for each node and for the controller because it refers to each of them by those names which will also be used for TLS certificate generation.

After this, you can select a branch you wish to run the test suite on by refering to it as `git::https://github.com/<user>/<repo>//flatcar-linux/kubernetes?ref=<branch>`
Running can be done in one of two ways : 
```
cd matchbox
terraform apply 
cd ..
terraform apply
```
or
```
./start_up.sh
```
the upside provided by running the `start_up.sh` script is that, if you run the test suite several times, it will take care of cleaning up and destroying the VMs, their volumes and the networks which you recently spun up in order to have a setup that is as fresh as possible.
