output "acm_certificate_arn" {
  value = module.acm.acm_certificate_arn
}

output "acm_dyn_certificate_arn" {
  value = join("", module.acm_dyn[*].acm_certificate_arn)
}