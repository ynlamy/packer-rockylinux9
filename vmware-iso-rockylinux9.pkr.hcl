// Creating a virtual machine template under Rocky Linux 9 from ISO file with Packer using VMware Workstation


packer {
  required_version = ">= 1.7.9"

  required_plugins {
    vmware = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/vmware"
    }
  }
}


# Variables for easy configuration and customization
variable "iso" {
  type        = string
  description = "URL to the Rocky Linux 9 ISO"
  default     = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-minimal.iso"
}

variable "checksum" {
  type        = string
  description = "The checksum of the ISO file"
  default     = "sha256:eedbdc2875c32c7f00e70fc861edef48587c7cbfd106885af80bdf434543820b"
}

variable "headless" {
  type        = bool
  description = "When this value is set to true, the machine will start without a console"
  default     = true
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine template"
  default     = "rocky9-template"
}

variable "username" {
  type        = string
  description = "SSH username for template creation"
  default     = "cunha"
}

variable "password" {
  type        = string
  description = "A plaintext password to authenticate with SSH"
  default     = "jncunha"
}


source "vmware-iso" "rockylinux9" {
  // https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

  // ISO configuration
  iso_url      = var.iso
  iso_checksum = var.checksum

  // Driver configuration
  cleanup_remote_cache = false

  // Virtual Machine Configuration
  vm_name       = var.vm_name
  vmdk_name     = var.vm_name
  version       = "21"
  guest_os_type = "rockylinux-64"

  // Hardware Resources
  cpus   = 2
  memory = 4096

  // Disk Configuration
  disk_size         = 20720
  disk_adapter_type = "scsi"
  disk_type_id      = "1"

  // Network and Peripheral Configuration
  network = "nat"

  sound   = false
  usb     = false

  // Run configuration
  headless = var.headless

  // Shutdown configuration
  shutdown_command = "sudo shutdown -P now"

  // Http directory configuration
  http_directory = "http"

  // Boot configuration
  boot_command = ["<up><wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  boot_wait    = "10s"

  // Communicator configuration
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "30m"

  // Output configuration
  output_directory = "template"

  // Export configuration
  format          = "vmx"
  skip_compaction = false
}


build {
  sources = ["source.vmware-iso.rockylinux9"]

  provisioner "shell" {
    # Scripts to run after base installation
    scripts = [
      "scripts/post-install.sh"
    ]

    # Environment variables for the provisioner
    environment_vars = [
      "USERNAME=${var.username}"
    ]

  }

  post-processor "compress" {
    output = "output/rocky9-template.tar.gz"
  }
  
}

