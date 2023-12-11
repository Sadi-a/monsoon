module "monsoon" {
  source = "git::https://github.com/sadi-a/monsoon//flatcar-linux/kubernetes?ref=sadi/live"
  # source = "git::https://github.com/aristanetworks/monsoon//flatcar-linux/kubernetes?ref=HEAD"

  # bare-metal
  cluster_name           = "monsoon-test"
  matchbox_http_endpoint = "http://192.168.100.1:8080"
  os_channel             = "flatcar-stable"
  os_version             = "3510.2.0"

  # configuration
  k8s_domain_name    = libvirt_domain.vm["controller100"].network_interface.0.hostname
  ssh_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAAmZYlpSJ4/GCSKwHS3QV+rU9QCOkd5/Z2iOxj8Wcg sadi@arista.com"
  oem_type           = ""
  enable_install     = local.enable_install
  install_disk       = local.install_disk
  networking         = "flannel"
  # set to http only if you cannot chainload to iPXE firmware with https support
  download_protocol = "http"

  # machines
  controllers = [
    for k, v in local.controllers :
    {
      name         = k,
      mac          = v.mac,
      domain       = join(".", [k, libvirt_network.monsoon_test.domain]),
      install_disk = v.install_disk
      persist_disk = v.persist_disk
      # cpu_architecture = v.cpu_architecture,
    }
  ]
  workers = [
    for k, v in local.workers :
    {
      name         = k,
      mac          = v.mac,
      domain       = join(".", [k, libvirt_network.monsoon_test.domain]),
      install_disk = v.install_disk
      persist_disk = v.persist_disk
      # cpu_architecture = v.cpu_architecture,
    }
  ]

  snippets = merge(
    local.snippets_controllers,
    local.snippets_workers
  )
  worker_node_labels = local.worker_node_labels
  worker_node_taints = local.worker_node_taints
  # worker_node_taints = local.worker_node_taints
  depends_on = [
    libvirt_domain.vm,
  ]
}

resource "local_sensitive_file" "kubeconfig-mercury" {
  content  = module.monsoon.kubeconfig-admin
  filename = "mercury-config"
}
