variable "YC_FOLDER_ID" {
  type = string
  description = "Yandex Cloud folder_id"
}

variable "YC_TOKEN" {
  type = string
  description = "Yandex Cloud token"
}

variable "YC_CLOUD_ID" {
  type = string
  description = "Yandex Cloud cloud_id"
}

#variable "image_id" {
#  type        = string
#  description = "ID image"
#}

variable "image_name" {
  type        = string
  description = "image name"
}

variable "image_tag" {
  type        = string
  description = "image tag"
}

variable "vm_count" {
  type        = number
  description = "Number of VM in group"
}

variable "cidr_blocks" {
  type        = list(list(string))
  description = "List of IPv4 cidr blocks for subnet"
}

variable "az" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}