output "windows_hostname" {
  description = "EC2(Windows) hostname for accessing via ZPA"
  value       = aws_instance.windows.private_dns
}

output "Azure_Application_FQDN" {
  description = "FQDN of Windows 10 which is created on Azure for accessing via ZPA"
  value       = zpa_application_segment.target.domain_names
}

output "admin_password" {
  sensitive = true
  value     = random_password.password.result
}
