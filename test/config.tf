locals {

  controllers = {
    controller100 = {
      mac              = "1e:6d:6e:73:6e:01",
      install_disk     = "/dev/vda"
      persist_disk     = "/dev/vdb",
      cpu_architecture = "x86_64",
      # cpu_architecture = "aarch64",
      # extra_selectors = { "test" : "0", "test2" : "1", },
    }
  }

  workers = {
    worker100 = {
      mac              = "2e:6d:6e:73:6e:01",
      install_disk     = "/dev/vda"
      persist_disk     = "/dev/vdb",
      cpu_architecture = "x86_64",
      # cpu_architecture = "aarch64", # doesn't work on most laptops bc kvm virtualization only really works when you virtualize with the same arch as the one you have on your CPU
      # extra_selectors = { "test" : "1", "test2" : "0", },
    }
  }

  nodes          = merge(local.controllers, local.workers)
  enable_install = false

  snippets_path = "snippets"
  snippets_coreos = [
    ### Coreos snippets
    # Configures and prepares the system in case we wish to use containerd
    file("./snippets/coreos/containerd-config.yaml"),
    # Mitigates a critical security vulnerability
    file("${local.snippets_path}/coreos/disable_spectre.yaml"),
    # Configures and prepares the system for using docker
    file("${local.snippets_path}/coreos/docker-config.yaml"),
    # enables ipv6
    file("${local.snippets_path}/coreos/enable_ipv6.yaml"),
    # sets the amount of events to monitor and report
    file("${local.snippets_path}/coreos/inotify.yaml"),
    # Generates a nice motd when logging in with SSH
    file("${local.snippets_path}/coreos/motdgen.yaml"),
    # Configures the network
    file("${local.snippets_path}/coreos/network_config.yaml"),
    # Mitigates a known bug originating from systemd
    file("${local.snippets_path}/coreos/systemd_udevd_bug.yaml"),

    # ### Barney snippets
    # Defines a service setting our I/O schedulers
    file("${local.snippets_path}/barney/ioscheduler.yaml"),
    # Sets the maximum socket read and write size to 8MiB
    file("${local.snippets_path}/barney/sysctl.yaml"),
  ]

  snippets_ssh = [file("snippets/ssh-keys.yaml"), ]

  snippets_workers = concat(
    local.snippets_coreos,
    local.snippets_ssh,
    [],
  )

  snippets_controllers = concat(
    local.snippets_ssh,
    [file("${local.snippets_path}/coreos/motdgen.yaml"), ],
    [],
  )

  snippets_worker100 = concat(
    local.snippets_workers,
    [
      templatefile(
        # binds the network interfaces together in order to use all the bandwith we can get
        "${local.snippets_path}/coreos/bond.yaml",
        {
          MACAddress = local.workers.worker100.mac,
      }),
      templatefile(
        # Creates the cache btrfs and mounts it
        "${local.snippets_path}/barney/btrfs.yaml",
        {
          diskno    = 2
          used_disk = local.enable_install ? local.workers.worker100.install_disk : local.workers.worker100.persist_disk
      }),
    ]
  )

  ###########################################################
  ######################     Taints     #####################
  ###########################################################


  barney_taints = [
    "type=barney:NoSchedule",
  ]
  barney_aux_taints = [
    "type=barney:NoSchedule",
  ]
  barney_bus_taints = [
    "type=bus:NoSchedule",
  ]

  worker_node_taints = {
    "worker100" = local.barney_taints,
  }

  ###########################################################
  ######################     Labels     #####################
  ###########################################################

  barney_labels = [
    # "node-role.kubernetes.io/barney=barney",
    "node-role/barney=barney",
    # "node-role.kubernetes.io/barney-kafka=barney-kafka",
    "node-role/barney-kafka=barney-kafka",
    # "node-role.kubernetes.io/barnzilla=barnzilla",
    "node-role/barnzilla=barnzilla",
    # "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "px/enabled=false",
  ]

  barney_aux_labels = [
    "node-role.kubernetes.io/barney-aux=barney-aux",
    "node-role/barney-aux=barney-aux",
    "node-role.kubernetes.io/barney-kafka=barney-kafka",
    "node-role/barney-kafka=barney-kafka",
    "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "px/enabled=false",
  ]

  barney_bus_labels = [
    "node-role.kubernetes.io/bus=bus",
    "node-role/bus=bus",
    "node-role.kubernetes.io/bus-node=bus-node",
    "node-role/bus-node=bus-node",
    "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "px/enabled=false",
  ]

  barney_aarch64_labels = [
    "node-role.kubernetes.io/barney-arm64=barney-arm64",
    "node-role/barney-arm64=barney-arm64",
    "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "px/enabled=false",
  ]

  worker_node_labels = {
    "worker100" = local.barney_labels,
  }

}
