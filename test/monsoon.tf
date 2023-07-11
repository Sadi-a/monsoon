module "monsoon" {
  source = "git::https://github.com/aristanetworks/monsoon//flatcar-linux/kubernetes?ref=HEAD"

  # bare-metal
  cluster_name           = "monsoon-test"
  matchbox_http_endpoint = "http://192.168.100.1:8080"
  os_channel             = "flatcar-stable"
  os_version             = "3510.2.0"

  # configuration
  k8s_domain_name    = libvirt_domain.vm["controller100"].network_interface.0.hostname
  ssh_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe3f8ynCl0eUV0VICJsQJBAfDCLHVvB8zQF7+/kadIg sadi@arista.com"

  install_disk = "/dev/vda"

  # machines
  controllers = [
    for k, v in local.controllers :
    {
      name   = k,
      mac    = v.mac,
      domain = join(".", [k, libvirt_network.monsoon_test.domain]),
    }
  ]
  workers = [
    for k, v in local.workers :
    {
      name   = k,
      mac    = v.mac,
      domain = join(".", [k, libvirt_network.monsoon_test.domain]),
    }
  ]

  # set to http only if you cannot chainload to iPXE firmware with https support
  # download_protocol = "http"

  depends_on = [
    libvirt_domain.vm
  ]
}
