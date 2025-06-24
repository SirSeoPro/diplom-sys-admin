#=============================== Переменные =================================

#-------------------------== Зона сети по умолчанию ==-----------------------
variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

#-----------------------== ID образа ОС по умолчанию ==----------------------
variable "yc_image_id" {
  description = "Debian 12 Yandex Cloud default image"
  default     = "fd8djec02sfvs6t3ojng"
}