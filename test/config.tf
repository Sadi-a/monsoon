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
      # cpu_architecture = "aarch64",
      # extra_selectors = { "test" : "1", "test2" : "0", },
    }
    worker101 = {
      name             = "worker101"
      mac              = "2e:6d:6e:73:6e:02",
      install_disk     = "/dev/vda"
      persist_disk     = "/dev/vdb",
      cpu_architecture = "x86_64",
      # cpu_architecture = "aarch64",
      # extra_selectors = { "test" : "2", "test2" : "3", },
    }
  }

  nodes          = merge(local.controllers, local.workers)
  enable_install = false
  install_disk   = "/dev/vda"

  ###########################################################
  ###################      Node roles     ###################
  ###########################################################

  node_bsy = [
    local.nodes.worker100,
  ]
  node_bsy_aarch64 = [
  ]
  node_bsy_head = [
  ]
  node_bsy_head_aarch64 = [
  ]
  node_barney_aux = [
    local.nodes.worker101,
  ]
  node_bus = [
  ]

  # The following roles are more specific, like if you want to activate a feature
  # For example, here, we wish to enable cgroups on some nodes, which is done
  # through the node_cgroups role

  node_cgroups = [
    local.nodes.controller100,
    local.nodes.worker100,
    local.nodes.worker101,
  ]

  node_bond = [
    local.nodes.controller100,
    local.nodes.worker100,
    local.nodes.worker101,
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
    # Configures the network and some system variables
    # needed for flannel
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

  snippets_ssh = [
    file("${local.snippets_path}/ssh-keys.yaml"),
  ]

  snippets_cgroups = [
    file("${local.snippets_path}/cgroups/cgroups.yaml"),
  ]

  snippets_workers_generic = concat(
    local.snippets_coreos,
    local.snippets_ssh,
    local.snippets_k8s,
  )

  ###########################################################
  ###############     Controller snippets     ###############
  ###########################################################

  snippets_controllers = tomap({ for node in local.controllers :
    [for name, n in local.controllers : name if n == node][0] => concat(
      local.snippets_ssh,
      [
        file("${local.snippets_path}/coreos/motdgen.yaml"),
      ],
    )
  })

  ###########################################################
  #################     Worker snippets     #################
  ###########################################################

  snippets_workers = tomap({ for node, _ in local.workers :
    node => concat(local.snippets_workers_generic, )
  })

  # Defining the bsy snippets map, including machine specific snippets
  snippets_workers_bsy = tomap({ for node in concat(local.node_bsy, local.node_bsy_aarch64, local.node_bsy_head, local.node_bsy_head_aarch64) :
    [for name, n in local.nodes : name if n == node][0] => concat(
      local.snippets_barney,
    )
  })

  snippets_workers_barney_aux = tomap({ for node in local.node_barney_aux :
    [for name, n in local.nodes : name if n == node][0] => concat([])
  })

  snippets_workers_bus = tomap({ for node in local.node_bus :
    [for name, n in local.nodes : name if n == node][0] => concat([]
    )
  })

  snippets_nodes_cgroups = tomap({ for node in local.node_cgroups :
    [for name, n in local.nodes : name if n == node][0] => concat(local.snippets_cgroups)
  })

  snippets_nodes_bond = tomap({ for node in local.node_bond :
    [for name, n in local.nodes : name if n == node][0] => concat(
      [
        # this one snippet is node specific as it requires some info about the node,
        # which is the reason we have to template it here.
        templatefile(
          # binds the network interfaces together in order to use all the bandwith we can get
          "${local.snippets_path}/bond/bond.yaml",
          {
            MACAddress = node.mac,
          }
        ),
      ],
    )
  })

  ###########################################################
  #################     Merging snippets     ################
  ###########################################################

  snippets_nodes = [
    local.snippets_workers,
    local.snippets_controllers,
    local.snippets_workers_bsy,
    local.snippets_workers_barney_aux,
    local.snippets_workers_bus,
    local.snippets_nodes_cgroups,
    local.snippets_nodes_bond,
  ]

  # What we do here isn't clear at first glance so let's explain :
  # for all our nodes, we put them in a list and go see in each list of
  # snippets if there are snippets associated to this node. We then concatenate
  # these snippets to all the others belonging to that node in order to end up
  # with all the snippets belonging to it.
  #
  # This has to be done because, when merging maps, the contents of the values
  # for duplicate keys are not appended to each other but overwritten
  # This is necessary as we can have one node in two roles, such as one node that
  # would belong to both the bsy and cgroup roles.

  snippets = { for node, _ in local.nodes :
    node =>
    distinct(concat([
      for snippets in local.snippets_nodes : concat([], [for node_, snips in snippets : snips if node == node_]...)
    ]...))
  }

  ###########################################################
  ######################     Taints     #####################
  ###########################################################

  barney_bsy_taints = [
    "type=barney:PreferNoSchedule",
  ]
  barney_aux_taints = [
    "type=barney_aux:PreferNoSchedule",
  ]
  barney_bus_taints = [
    "type=bus:PreferNoSchedule",
  ]

  ###########################################################
  ##################     Worker taints     ##################
  ###########################################################

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_bsy = tomap({ for node in concat(local.node_bsy, local.node_bsy_aarch64, local.node_bsy_head, local.node_bsy_head_aarch64) :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_bsy_taints,
    )
  })

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_barney_aux = tomap({ for node in local.node_barney_aux :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_aux_taints,
    )
  })

  # Defining the bsy snippets map, including machine specific snippets
  taints_workers_bus = tomap({ for node in local.node_bus :
    [for name, n in local.workers : name if n == node][0] => concat(
      local.barney_bus_taints,
    )
  })

  ###########################################################
  ##################     Merging taints     #################
  ###########################################################

  taints_nodes = [
    local.taints_workers_bsy,
    local.taints_workers_barney_aux,
    local.taints_workers_bus,
  ]

  worker_node_taints = { for node, _ in local.workers :
    node =>
    distinct(concat([
      for taints in local.taints_nodes : concat([], [for node_, taint in taints : taint if node == node_]...)
    ]...))
  }

  ###########################################################
  ######################     Labels     #####################
  ###########################################################

  worker_labels = [
    "node-role/worker=worker",
    "role/worker=worker",
    "px/enabled=false",
    "app/managed-by=monsoon.git",
  ]

  roles = {
    "bsy" = [
      "barney",
      "barnzilla",
      "barney-kafka"
    ],
    "bsy_test" = [
      "barney-test"
    ],
    "bsy_aarch64" = [
      "barney-arm64"
    ],
    "bsy_test_aarch64" = [
      "barney-test-arm64"
    ],
    "barney_aux" = [
      "barney-aux",
      "barney-kafka"
    ],
    "bus" = [
      "bus"
    ],
  }

  role_specific_labels = {
    "bsy" = [
      "environment=demo-bsy"
    ],
    "bsy_test" = [
      "environment=demo-bsy-head"
    ],
    "bsy_aarch64" = [
      "environment=demo-bsy-aarch64"
    ],
    "bsy_test_aarch64" = [
      "environment=demo-bsy-head-aarch64"
    ],
    "barney_aux" = [
      "environment=demo-bsy-aux"
    ],
    "bus" = [
      "environment=demo-bus"
    ],
  }

  # Defining the labels map, which will be assigned to each machine later
  labels = { for generic, roles in local.roles :
    generic => concat(
      local.worker_labels,
      [for role in roles : "node-role/${role}=${role}"],
      [for role in roles : "role/${role}=${role}"],
      [for label in local.role_specific_labels[generic] : label],
    )
  }

  ###########################################################
  ##################     Worker labels     ##################
  ###########################################################

  # Defining the bsy labels
  labels_workers_bsy = { for node in local.node_bsy :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "bsy")
  }

  labels_workers_bsy_head = { for node in local.node_bsy_head :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "bsy_head")
  }

  labels_workers_bsy_aarch64 = { for node in local.node_bsy_aarch64 :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "bsy_aarch64")
  }

  labels_workers_bsy_head_aarch64 = { for node in local.node_bsy_head_aarch64 :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "bsy_head_aarch64")
  }

  # Defining the bsy snippets map, including machine specific snippets
  labels_workers_barney_aux = { for node in local.node_barney_aux :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "barney_aux")
  }

  # Defining the bsy snippets map, including machine specific snippets
  labels_workers_bus = { for node in local.node_bus :
    [for name, n in local.workers : name if n == node][0] => lookup(local.labels, "bus")
  }

  ###########################################################
  ##################     Merging labels     #################
  ###########################################################

  labels_nodes = [
    local.labels_workers_bsy,
    local.labels_workers_bsy_head,
    local.labels_workers_bsy_aarch64,
    local.labels_workers_bsy_head_aarch64,
    local.labels_workers_barney_aux,
    local.labels_workers_bus,
  ]

  # have to set machine specific taints
  worker_node_labels = { for node, _ in local.workers :
    node =>
    distinct(concat([
      for labels in local.labels_nodes : concat([], [for node_, label in labels : label if node == node_]...)
    ]...))
  }

}
