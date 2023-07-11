virsh net-undefine monsoon-test
virsh net-destroy monsoon-test
virsh destroy controller100
virsh destroy worker100
virsh undefine controller100
virsh undefine worker100
rm -f /var/lib/libvirt/images/controller100_os_disk > /dev/null
rm -f /var/lib/libvirt/images/controller100_persistent > /dev/null
rm -f /var/lib/libvirt/images/worker100_os_disk > /dev/null
rm -f /var/lib/libvirt/images/worker100_persistent > /dev/null

cd matchbox
docker stop copy_ipxe matchbox > /dev/null
docker rm copy_ipxe matchbox > /dev/null
rm terraform.tfstate > /dev/null
rm terraform.tfstate.backup > /dev/null
terraform apply -auto-approve
cd ..
rm terraform.tfstate
rm terraform.tfstate.backup
terraform apply -auto-approve
