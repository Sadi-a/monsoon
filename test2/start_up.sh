virsh net-undefine monsoon-test2
virsh net-destroy monsoon-test2
virsh destroy controller102
virsh destroy worker102
virsh undefine controller102
virsh undefine worker102
rm -f /var/lib/libvirt/images/controller102_os_disk > /dev/null
rm -f /var/lib/libvirt/images/controller102_persistent > /dev/null
rm -f /var/lib/libvirt/images/worker102_os_disk > /dev/null
rm -f /var/lib/libvirt/images/worker102_persistent > /dev/null
rm terraform.tfstate
rm terraform.tfstate.backup

# cd matchbox
# docker stop copy_ipxe matchbox > /dev/null
# docker rm copy_ipxe matchbox > /dev/null
# rm terraform.tfstate > /dev/null
# rm terraform.tfstate.backup > /dev/null
# terraform apply -auto-approve
# cd ..
terraform apply -auto-approve

