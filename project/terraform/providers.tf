#========================= Провайдер для terraform ==========================

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  cloud_id  = "**********"
  folder_id = "************"
  service_account_key_file = file("~/key.json")
}
