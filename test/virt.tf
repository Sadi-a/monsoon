resource "libvirt_network" "monsoon_test" {

  name   = "monsoon-test"
  mode   = "nat"
  domain = "k8s.local"

  addresses = [
    "192.168.100.0/24",
  ]

  bridge = "monsoon0"

  dhcp {
    enabled = true
  }

  dns {
    enabled = true
    hosts {
      hostname = "gateway.k8s.local"
      ip       = "192.168.100.1"
    }
    hosts {
      hostname = "controller100.k8s.local"
      ip       = "192.168.100.68"
    }
    hosts {
      hostname = "worker100.k8s.local"
      ip       = "192.168.100.158"
    }
  }

  dnsmasq_options {
    # We must tell dnsmasq to give different ipxe firmwares depending on the
    # architecture. The way this works is that we set a unique tag per
    # architecture+boot method based on the numeric value of the client-arch
    # DHCP option.
    #
    # Valid values for client-arch are:
    #
    # 0x00	BIOS pxeboot (both i386 and x86_64)
    # 0x06	EFI pxeboot, IA32 (i386)
    # 0x07	EFI pxeboot, X64 (x86_64)
    # 0x0a	EFI pxeboot, ARM (v7)
    # 0x0b	EFI pxeboot, AA64 (v8 / aarch64)
    # 0x12	powerpc64
    # 0x16	EFI httpboot, X64
    # 0x18	EFI httpboot, ARM
    # 0x19	EFI httpboot, AA64
    # 0x31	s390x

    # BIOS PXE x86_64
    options {
      option_name  = "dhcp-match"
      option_value = "set:efi-x64-pxe,option:client-arch,0"
    }
    options {
      option_name = "dhcp-boot"
      # This isn't normally technically correct, as it abuses a feature of ipxe http offloading from pxe.
      option_value = "tag:efi-x64-pxe,\"http://gateway.k8s.local:8080/assets/ipxe/x86_64/undionly.kpxe\""
    }

    # UEFI-HTTP x86_64
    options {
      option_name  = "dhcp-match"
      option_value = "set:efi-x64-http,option:client-arch,16"
    }
    options {
      option_name = "dhcp-boot"
      option_value = "tag:efi-x64-http,\"http://gateway.k8s.local:8080/assets/ipxe/x86_64/undionly.kpxe\""
    }
    options {
      option_name  = "dhcp-option-force"
      option_value = "tag:efi-x64-http,60,HTTPClient"
    }

    # UEFI-HTTP aarch64
    options {
      option_name  = "dhcp-match"
      option_value = "set:efi-aa64-http,option:client-arch,19"
    }
    options {
      option_name = "dhcp-boot"
      option_value = "tag:efi-aa64-http,\"http://gateway.k8s.local:8080/assets/ipxe/aarch64/snponly.efi\""
    }
    options {
      option_name  = "dhcp-option-force"
      option_value = "tag:efi-aa64-http,60,HTTPClient"
    }
  }
}

resource "libvirt_volume" "os_disk" {
  format   = "qcow2"
  for_each = local.nodes
  name     = "${each.key}_os_disk"
  // 35GB for each machine, minimum required in the doc is
  // 30GB, we try to get just a bit of leeway
  size     = 35 * 1024 * 1024 * 1024
}

resource "libvirt_domain" "vm" {
  for_each = local.nodes
  name     = each.key
  memory   = 4096
  vcpu     = 2
  // x86_64 config uses the machine type exclusive for it
  // The same is done for aarch64 configs
  machine = "q35"
  arch    = "x86_64"
  boot_device {
    dev = ["hd", "network"]
  }

  autostart = true

  disk {
    volume_id = libvirt_volume.os_disk[each.key].id
  }

  network_interface {
    network_id     = libvirt_network.monsoon_test.id
    hostname       = join(".", [each.key, libvirt_network.monsoon_test.domain])
    mac            = each.value.mac
    wait_for_lease = true
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}
