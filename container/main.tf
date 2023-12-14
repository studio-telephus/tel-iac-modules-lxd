locals {
  files = flatten(tolist([for d in var.mount_dirs : [for f in fileset(d, "**") : {
    source = "${d}/${f}"
    target = "/${f}"
  }]]))
  lxc_set_environment = { for key, value in var.exec.environment : "G76HJU3RFV_${key}" => "environment.${key}=${value}" }
  lxc_set_environment2 = {
    "G76HJU3RFV_A" = "environment.A=B"
  }
}

resource "lxd_container" "container" {
  name      = var.name
  image     = var.image
  profiles  = var.profiles
  ephemeral = false

  config = {
    "boot.autostart" = var.autostart
  }

  device {
    name       = var.nic.name
    type       = "nic"
    properties = var.nic.properties
  }

  dynamic "file" {
    for_each = local.files
    content {
      source             = file.value.source
      target_file        = file.value.target
      create_directories = true
    }
  }
}

resource "null_resource" "local_exec_condition" {
  count = var.exec.enabled ? 1 : 0

  provisioner "local-exec" {
    command     = <<-EXEC
      env
      while IFS='=' read -r key value ; do
        lxc config set ${var.name} $value
      done < <(env | grep "G76HJU3RFV_")
      lxc exec ${var.name} -- bash -xe -c 'chmod +x ${var.exec.entrypoint} && ${var.exec.entrypoint}'
    EXEC
    interpreter = ["/bin/bash", "-c"]
    environment = local.lxc_set_environment
  }
  depends_on = [lxd_container.container]
}

resource "lxd_volume_container_attach" "volume_attach" {
  count          = length(var.volumes)
  pool           = var.volumes[count.index].pool
  volume_name    = var.volumes[count.index].volume_name
  container_name = lxd_container.container.name
  path           = var.volumes[count.index].path
  depends_on     = [lxd_container.container]
}
