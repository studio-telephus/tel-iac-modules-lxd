variable "name" {
  type = string
}

variable "image" {
  type    = string
  default = "images:debian/bookworm"
}

variable "profiles" {
  type    = list(string)
  default = []
}

variable "nic" {
  type = object({
    name       = string
    properties = map(string)
  })
}

variable "volumes" {
  type = list(object({
    pool        = string
    volume_name = string
    path        = string
  }))
  default = []
}

variable "autostart" {
  type    = bool
  default = false
}

variable "mount_dirs" {
  type = list(string)
}

variable "exec" {
  type = object({
    enabled     = bool
    entrypoint  = string
    environment = map(any)
  })
  sensitive   = true
}

