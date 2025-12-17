output "nginx_container_name" {
  description = "Name of the Nginx container"
  value       = docker_container.nginx.name
}

output "php_fpm_container_name" {
  description = "Name of the PHP-FPM container"
  value       = docker_container.php_fpm.name
}

output "healthz_url" {
  description = "Health check endpoint URL"
  value       = "http://localhost:${var.host_port}/healthz"
}

output "application_url" {
  description = "Application URL"
  value       = "http://localhost:${var.host_port}/"
}

output "published_port" {
  description = "Published port on host"
  value       = var.host_port
}