locals {

  controllers = {
    controller100 = {
      name             = "controller100"
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
      name             = "worker100"
      mac              = "2e:6d:6e:73:6e:01",
      install_disk     = "/dev/vda"
      persist_disk     = "/dev/vdb",
      cpu_architecture = "x86_64",
      # cpu_architecture = "aarch64",
      # extra_selectors = { "test" : "1", "test2" : "0", },
    }
  }

  nodes          = merge(local.controllers, local.workers)
  enable_install = false
  install_disk   = "/dev/vda"

  ###########################################################
  ###################      Node roles     ###################
  ###########################################################

  node_bsy = [
    local.workers.worker100,
  ]
  node_bsy_aarch64 = [
  ]
  node_bsy_head = [
  ]
  node_bsy_head_aarch64 = [
  ]
  node_barney_aux = [
  ]
  node_bus = [
  ]

  ###########################################################
  ####################      Snippets     ####################
  ###########################################################

  snippets_path = "snippets"
  snippets_coreos = [
    ### Coreos snippets
    # Configures and prepares the system in case we wish to use containerd
    file("${local.snippets_path}/coreos/containerd-config.yaml"),
    # Mitigates a critical security vulnerability
    file("${local.snippets_path}/coreos/disable_spectre.yaml"),
    # Configures and prepares the system for using docker
    file("${local.snippets_path}/coreos/docker-config.yaml"),
    # enables ipv6
    file("${local.snippets_path}/coreos/enable_ipv6.yaml"),
    # disables auto-updates
    file("${local.snippets_path}/coreos/etcd.yaml"),
    # sets the amount of events to monitor and report
    file("${local.snippets_path}/coreos/inotify.yaml"),
    # Generates a nice motd when logging in with SSH
    file("${local.snippets_path}/coreos/motdgen.yaml"),
    # Configures the network
    file("${local.snippets_path}/coreos/network_config.yaml"),
    # Mitigates a known bug originating from systemd
    file("${local.snippets_path}/coreos/systemd_udevd_bug.yaml"),
  ]

  snippets_barney = [
    ### Barney snippets
    # Defines a service setting our I/O schedulers
    file("${local.snippets_path}/barney/ioscheduler.yaml"),
    # Sets the maximum socket read and write size to 8MiB
    file("${local.snippets_path}/barney/sysctl.yaml"),
    # enables cgroupv2
    file("${local.snippets_path}/barney/cgroups.yaml"),
    # Creates the cache btrfs and mounts it
    templatefile(
      "${local.snippets_path}/barney/btrfs.yaml",
      {
        diskno = 2
      }
    ),
  ]

  snippets_k8s = [
    ### k8s snippets
    # Defines a service setting our I/O schedulers
    file("${local.snippets_path}/k8s_cluster/main.yaml"),
  ]

  snippets_ssh = [file("${local.snippets_path}/ssh-keys.yaml"), ]

  snippets_workers_generic = concat(
    local.snippets_coreos,
    local.snippets_ssh,
    local.snippets_k8s,
  )

  ###########################################################
  ###############     Controller snippets     ###############
  ###########################################################

  snippets_controllers = { for node in local.controllers :
    [for name, n in local.controllers : name if n == node][0] => concat(
      local.snippets_ssh,
      [
        file("${local.snippets_path}/coreos/motdgen.yaml"),
      #   # templatefile(
      # #     # binds the network interfaces together in order to use all the bandwith we can get
      # #     "${local.snippets_path}/bond/bond.yaml",
      # #     {
      # #       MACAddress = node.mac,
      # #     }
      # #   ),
      ],
    )
  }

  ###########################################################
  #################     Worker snippets     #################
  ###########################################################

  # Defining the bsy snippets map, including machine specific snippets
  snippets_workers_bsy = { for node in concat(local.node_bsy, local.node_bsy_aarch64, local.node_bsy_head, local.node_bsy_head_aarch64) :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.snippets_workers_generic,
      local.snippets_barney,
      [
        templatefile(
          # binds the network interfaces together in order to use all the bandwith we can get
          "${local.snippets_path}/bond/bond.yaml",
          {
            MACAddress = node.mac,
          }
        ),
      ],
    )
  }

  snippets_workers_barney_aux = { for node in local.node_barney_aux :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.snippets_workers_generic,
      [
        templatefile(
          # binds the network interfaces together in order to use all the bandwith we can get
          "${local.snippets_path}/bond/bond.yaml",
          {
            MACAddress = node.mac,
          }
        ),
      ],
    )
  }

  snippets_workers_bus = { for node in local.node_bus :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.snippets_workers_generic,
      [
        templatefile(
          # binds the network interfaces together in order to use all the bandwith we can get
          "${local.snippets_path}/bond/bond.yaml",
          {
            MACAddress = node.mac,
          }
        ),
      ],
    )
  }

  snippets_workers = merge(
    local.snippets_workers_bsy,
    local.snippets_workers_bus,
    local.snippets_workers_barney_aux,
  )

  ###########################################################
  ######################     Taints     #####################
  ###########################################################


  # barney_bsy_taints = [
  #   "type=barney:NoSchedule",
  # ]
  barney_bsy_taints = [
    "type=barney",
  ]
  barney_aux_taints = [
    "type=barney:NoSchedule",
  ]
  barney_bus_taints = [
    "type=bus:NoSchedule",
  ]

  ###########################################################
  ##################     Worker taints     ##################
  ###########################################################

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_bsy = { for node in concat(local.node_bsy, local.node_bsy_aarch64, local.node_bsy_head, local.node_bsy_head_aarch64) :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_bsy_taints,
    )
  }

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_barney_aux = { for node in local.node_barney_aux :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_aux_taints,
    )
  }

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_bus = { for node in local.node_bus :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_bus_taints,
    )
  }

  # have to set machine specific taints
  worker_node_taints = merge(
    local.taints_workers_bsy,
    local.taints_workers_barney_aux,
    local.taints_workers_bus
  )

  ###########################################################
  ######################     Labels     #####################
  ###########################################################

  worker_labels = [
    "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "px/enabled=false",
  ]

  barney_bsy_labels = [
    "node-role.kubernetes.io/barney=barney",
    "role/barney=barney",
    "node-role.kubernetes.io/barnzilla=barnzilla",
    "role=barnzilla",
    "node-role.kubernetes.io/docker=docker",
    "node-role/docker=docker",
  ]

  barney_bsy_head_labels = [
    "node-role.kubernetes.io/barney-test=barney-test",
    "node-role/barney-test=barney-test",
  ]

  barney_bsy_aarch64_labels = [
    "node-role.kubernetes.io/barney-arm64=barney-arm64",
    "node-role/barney-arm64=barney-arm64",
    "node-role.kubernetes.io/docker=docker",
    "node-role/docker=docker",
  ]

  barney_bsy_head_aarch64_labels = [
    "node-role.kubernetes.io/barney-test-arm64=barney-test-arm64",
    "node-role/barney-test-arm64=barney-test-arm64",
  ]

  barney_aux_labels = [
    "px/enabled=false",
    "node-role.kubernetes.io/worker=worker",
    "node-role/worker=worker",
    "node-role/barney-aux=barney_aux",
    "node-role.kubernetes.io/barney-aux=barney-aux",
    "node-role/barney-aux=barney-aux",
    "node-role.kubernetes.io/barney-kafka=barney-kafka",
    "node-role/barney-kafka=barney-kafka",
    "node-role.kubernetes.io/docker=docker",
    "node-role/docker=docker",
  ]

  barney_bus_labels = [
    "node-role.kubernetes.io/bus=bus",
    "node-role/bus=bus",
    "node-role.kubernetes.io/bus-node=bus-node",
    "node-role/bus-node=bus-node",
    "node-role.kubernetes.io/docker=docker",
    "node-role/docker=docker",
  ]

  ###########################################################
  ##################     Worker labels     ##################
  ###########################################################


  # Defining the bsy snippets map, including machine specific snippets
  labels_workers_bsy = { for node in local.node_bsy :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.worker_labels,
      local.barney_bsy_labels,
    )
  }

  labels_workers_bsy_head = { for node in local.node_bsy_head :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.worker_labels,
      local.barney_bsy_head_labels,
    )
  }

  labels_workers_bsy_aarch64 = { for node in local.node_bsy_aarch64 :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.worker_labels,
      local.barney_bsy_aarch64_labels,
    )
  }

  labels_workers_bsy_head_aarch64 = { for node in local.node_bsy_head_aarch64 :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.worker_labels,
      local.barney_bsy_head_aarch64_labels,
    )
  }

  # Defining the bsy snippets map, including machine specific snippets
  labels_workers_barney_aux = { for node in local.node_barney_aux :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.worker_labels,
      local.barney_aux_labels,
    )
  }

  # Defining the bsy snippets map, including machine specific snippets
  labels_workers_bus = { for node in local.node_bus :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_bus_labels,
    )
  }

  # have to set machine specific taints
  worker_node_labels = merge(
    local.labels_workers_bsy,
    local.labels_workers_bsy_aarch64,
    local.labels_workers_barney_aux,
    local.labels_workers_bus,
  )

}
