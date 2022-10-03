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

  dynamic file {
    for_each = var.files
    content {
      source             = file.value.source
      target_file        = file.value.target
      create_directories = true
    }
  }

  provisioner "local-exec" {
    command     = <<-EXEC
      echo "Tere"
      env
      while IFS='=' read -r key value ; do
        lxc config set ${self.name} environment.$key=$value
      done < <(env | grep "")
      lxc exec ${self.name} -- bash -xe -c 'chmod +x ${var.exec.entrypoint} && ${var.exec.entrypoint}'
    EXEC
    interpreter = ["/bin/bash", "-c"]
    environment = var.exec.environment
  }
}

resource "lxd_volume_container_attach" "volume_attach" {
  count          = length(var.volumes)
  pool           = var.volumes[count.index].pool
  volume_name    = var.volumes[count.index].volume_name
  container_name = lxd_container.container.name
  path           = var.volumes[count.index].path
  depends_on     = [lxd_container.container]
}
