variable "name" {
  type = string
}

variable "image" {
  type    = string
  default = "images:debian/bullseye"
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

variable "files" {
  type = object({
    target = string
    set    = set(string)
  })
}

variable "exec" {
  type = object({
    entrypoint  = string
    environment = map(any)
  })
}

