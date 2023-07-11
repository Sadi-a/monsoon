locals {

  controllers = {
    controller100 = {
      mac = "1e:6d:6e:73:6e:01",
      cpu_architecture = "x86_64",
    }
  }

  workers = {
    worker100 = {
      mac = "2e:6d:6e:73:6e:01",
      cpu_architecture = "x86_64",
    }
  }

  nodes = merge(local.controllers, local.workers)

}
