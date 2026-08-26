output "hosts" {
  value       = module.apigee.hosts
  description = "Internal hostnames of the Apigee runtime instances, keyed by instance name"
}
