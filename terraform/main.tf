terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "${var.project_name}-network"
}

resource "docker_volume" "web_volume" {
  name = "${var.project_name}-volume"
}

resource "docker_image" "php_fpm" {
  name = "php:8.2-fpm"
}

resource "docker_container" "php_fpm" {
  name  = "${var.project_name}-php-fpm"
  image = docker_image.php_fpm.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    volume_name    = docker_volume.web_volume.name
    container_path = "/var/www/html"
  }

  env = ["APP_ENV=${var.app_env}"]

  restart = "unless-stopped"
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name  = "${var.project_name}-nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.host_port
  }
  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    volume_name    = docker_volume.web_volume.name
    container_path = "/var/www/html"
    read_only      = true
  }

  # Upload nginx config directly to container
  upload {
    content = templatefile("${path.module}/nginx.conf.tpl", {
      php_fpm_container = "${var.project_name}-php-fpm"
    })
    file = "/etc/nginx/conf.d/default.conf"
  }

  env = ["APP_ENV=${var.app_env}"]

  restart = "unless-stopped"

  depends_on = [docker_container.php_fpm]
}

resource "null_resource" "copy_php_files" {
  triggers = {
    php_content = filemd5("${path.module}/index.php")
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker run --rm \
        -v ${var.project_name}-volume:/var/www/html \
        -v ${path.module}/index.php:/tmp/index.php:ro \
        alpine sh -c "cp /tmp/index.php /var/www/html/ && chmod 644 /var/www/html/index.php"
    EOT
  }

  depends_on = [
    docker_volume.web_volume,
    docker_container.php_fpm
  ]
}