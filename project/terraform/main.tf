#считываем данные об образе ОС
data "yandex_compute_image" "debian-12" {
  family = "debian-12"
}

#=========================== Создаваемые машины =============================

#-------------------------------== Web-1 ==----------------------------------

resource "yandex_compute_instance" "web-srv-1" {

  name = "web-srv-1"
  hostname = "web-srv-1"
  zone = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.network_a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.ssh-traffic-bars.id, yandex_vpc_security_group.webservers-bars.id]
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
}

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#-------------------------------== Web-2 ==----------------------------------

resource "yandex_compute_instance" "web-srv-2" {

  name = "web-srv-2"
  hostname = "web-srv-2"
  zone = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.network_b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.ssh-traffic-bars.id, yandex_vpc_security_group.webservers-bars.id]
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
}

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#-----------------------------== Prometheus ==-------------------------------

resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  hostname    = "prometheus"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.network_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.prometheus-bars.id, yandex_vpc_security_group.ssh-traffic-bars.id]
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#------------------------------== Grafana ==---------------------------------

resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  hostname    = "grafana"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.network_b.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.grafana-bars.id, yandex_vpc_security_group.ssh-traffic-bars.id]
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#----------------------------== Elasticsearch ==-----------------------------

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.network_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch-bars.id, yandex_vpc_security_group.ssh-traffic-bars.id]
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#-------------------------------== Kibana ==---------------------------------

resource "yandex_compute_instance" "kibana" {
  name     = "kibana"
  hostname = "kibana"
  zone     = "ru-central1-a"
  platform_id = "standard-v3"
  
  resources {
    cores         = 4
    memory        = 4
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.network_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana-bars.id, yandex_vpc_security_group.ssh-traffic-bars.id]
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#------------------------------== Bastion-host ==---------------------------------

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2              # кол-во ядер
    memory = 2              # память в гигабайтах
    core_fraction = 20      # процент от полной производительности vCPU
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yc_image_id}"
      size     = 20                         # размер диска в ГБ
      type     = "network-hdd"              # тип диска (network-hdd, network-ssd, network-ssd-nonreplicated)
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.network_b.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.bastion-bars.id]
  }

  metadata = {
  user-data          = file("./cloud-init.yml")
  serial-port-enable = 1
}

  scheduling_policy {preemptible = true}   # Включаем прерываемость

}

#-----------------== Создаем файл inventory.ini для ansible ==---------------

resource "local_file" "inventory" {
  content  = <<-EOT
    [bastion_gp]
    bastion ansible_host=${yandex_compute_instance.bastion.fqdn} public_ip=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} 

    [webservers_gp]
    web-srv-1 ansible_host=${yandex_compute_instance.web-srv-1.fqdn}
    web-srv-2 ansible_host=${yandex_compute_instance.web-srv-2.fqdn}
   
    [prometheus_gp]
    prometheus ansible_host=${yandex_compute_instance.prometheus.fqdn}

    [grafana_gp]
    grafana ansible_host=${yandex_compute_instance.grafana.fqdn} public_ip=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} 

    [elasticsearch_gp]
    elasticsearch ansible_host=${yandex_compute_instance.elasticsearch.fqdn}

    [kibana_gp]
    kibana ansible_host=${yandex_compute_instance.kibana.fqdn} public_ip=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} 
    
    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -W %h:%p -q barsukov@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    EOT
  filename = "../ansible/inventory.ini"
}
