# Terraform 0.13+ requires providers to be declared in a "required_providers" block
# https://registry.terraform.io/providers/fastly/fastly/latest/docs
terraform {
 required_providers {
   fastly = {
     source  = "fastly/fastly"
     version = ">= 3.0.4"
   }
   sigsci = {
     source = "signalsciences/sigsci"
     version = ">= 1.2.18"
   }
 }
}
# Fastly Edge VCL configuration
variable "FASTLY_API_KEY" {
   type        = string
   description = "This is API key for the Fastly VCL edge configuration."
}
#### VCL Service variables - Start
variable "USER_VCL_SERVICE_DOMAIN_NAME" {
 type = string
 description = "Frontend domain for your service. Try 'YOURNAME.global.ssl.fastly.net' to get up and running quickly."
 default = "<YOUR-CUSTOM-FASTLY-DOMAIN>.global.ssl.fastly.net"
}
variable "USER_VCL_SERVICE_BACKEND_HOSTNAME" {
 type          = string
 description   = "hostname used for backend."
 default       = "<YOUR COMPUTE@EDGE SERVICE DOMAIN>" # Generated after thee creation of a compute service via Fastly CLI
}
# Controls the percentage of traffic sent to NGWAF
variable "Edge_Security_dictionary" {
 type = string
 default = "Edge_Security"
}
variable "NGWAF_CORP" {
 type          = string
 description   = "Corp name for NGWAF"
}
variable "NGWAF_SITE" {
 type          = string
 description   = "Site name for NGWAF"
}
#### VCL Service variables - End
#### NGWAF variables - Start
variable "NGWAF_EMAIL" {
   type        = string
   description = "Email address associated with the token for the NGWAF API."
}
variable "NGWAF_TOKEN" {
   type        = string
   description = "Secret token for the NGWAF API."
   sensitive   = true
}
#### NGWAF variables - End
# Configure the Fastly Provider
provider "fastly" {
 api_key = var.FASTLY_API_KEY
}
#### Fastly VCL Service - Start
resource "fastly_service_vcl" "frontend-vcl-service" {
 name = "Edge WAF - Terraform"
 domain {
   name    = var.USER_VCL_SERVICE_DOMAIN_NAME
   comment = "Frontend VCL Service - NGWAF edge deploy"
 }
 backend {
   address = var.USER_VCL_SERVICE_BACKEND_HOSTNAME
   name = "Compute API Security Gateway"
   port    = 443
   use_ssl = true
   ssl_cert_hostname = var.USER_VCL_SERVICE_BACKEND_HOSTNAME
   ssl_sni_hostname = var.USER_VCL_SERVICE_BACKEND_HOSTNAME
   override_host = var.USER_VCL_SERVICE_BACKEND_HOSTNAME
 }
 #### NGWAF Dynamic Snippets - MANAGED BY FASTLY - Start
  dynamicsnippet {
    name     = "ngwaf_config_init"
    type     = "init"
    priority = 0
  }
  dynamicsnippet {
    name     = "ngwaf_config_miss"
    type     = "miss"
    priority = 9000
  }
  dynamicsnippet {
    name     = "ngwaf_config_pass"
    type     = "pass"
    priority = 9000
  }
  dynamicsnippet {
    name     = "ngwaf_config_deliver"
    type     = "deliver"
    priority = 9000
  }
 #### NGWAF Dynamic Snippets - MANAGED BY FASTLY - End
 dictionary {
   name       = var.Edge_Security_dictionary
 }
 lifecycle {
   ignore_changes = [
     product_enablement,
   ]
 }
 force_destroy = true
}
resource "fastly_service_dictionary_items" "edge_security_dictionary_items" {
 for_each = {
 for d in fastly_service_vcl.frontend-vcl-service.dictionary : d.name => d if d.name == var.Edge_Security_dictionary
 }
 service_id = fastly_service_vcl.frontend-vcl-service.id
 dictionary_id = each.value.dictionary_id
 items = {
   Enabled: "100"
 }
}
resource "fastly_service_dynamic_snippet_content" "ngwaf_config_init" {
 for_each = {
 for d in fastly_service_vcl.frontend-vcl-service.dynamicsnippet : d.name => d if d.name == "ngwaf_config_init"
 }
 service_id = fastly_service_vcl.frontend-vcl-service.id
 snippet_id = each.value.snippet_id
 content = "### Fastly managed ngwaf_config_init"
 manage_snippets = false
}
resource "fastly_service_dynamic_snippet_content" "ngwaf_config_miss" {
 for_each = {
 for d in fastly_service_vcl.frontend-vcl-service.dynamicsnippet : d.name => d if d.name == "ngwaf_config_miss"
 }
 service_id = fastly_service_vcl.frontend-vcl-service.id
 snippet_id = each.value.snippet_id
 content = "### Fastly managed ngwaf_config_miss"
 manage_snippets = false
}
resource "fastly_service_dynamic_snippet_content" "ngwaf_config_pass" {
 for_each = {
 for d in fastly_service_vcl.frontend-vcl-service.dynamicsnippet : d.name => d if d.name == "ngwaf_config_pass"
 }
 service_id = fastly_service_vcl.frontend-vcl-service.id
 snippet_id = each.value.snippet_id
 content = "### Fastly managed ngwaf_config_pass"
 manage_snippets = false
}
resource "fastly_service_dynamic_snippet_content" "ngwaf_config_deliver" {
  for_each = {
  for d in fastly_service_vcl.frontend-vcl-service.dynamicsnippet : d.name => d if d.name == "ngwaf_config_deliver"
  }
  service_id = fastly_service_vcl.frontend-vcl-service.id
  snippet_id = each.value.snippet_id
  content = "### Fastly managed ngwaf_config_deliver"
  manage_snippets = false
}
#### Fastly VCL Service - End
#### NGWAF Edge deploy - Start
provider "sigsci" {
  corp = var.NGWAF_CORP
  email = var.NGWAF_EMAIL
  auth_token = var.NGWAF_TOKEN
  fastly_api_key = var.FASTLY_API_KEY
}
resource "sigsci_edge_deployment" "ngwaf_edge_site_service" {
 # https://registry.terraform.io/providers/signalsciences/sigsci/latest/docs/resources/edge_deployment
 site_short_name = var.NGWAF_SITE
}
resource "sigsci_edge_deployment_service" "ngwaf_edge_service_link" {
 # https://registry.terraform.io/providers/signalsciences/sigsci/latest/docs/resources/edge_deployment_service
 site_short_name = var.NGWAF_SITE
 fastly_sid      = fastly_service_vcl.frontend-vcl-service.id
 activate_version = true
 percent_enabled = 100
 depends_on = [
   sigsci_edge_deployment.ngwaf_edge_site_service,
   fastly_service_vcl.frontend-vcl-service,
   fastly_service_dictionary_items.edge_security_dictionary_items,
   fastly_service_dynamic_snippet_content.ngwaf_config_init,
   fastly_service_dynamic_snippet_content.ngwaf_config_miss,
   fastly_service_dynamic_snippet_content.ngwaf_config_pass,
   fastly_service_dynamic_snippet_content.ngwaf_config_deliver,
 ]
}
resource "sigsci_edge_deployment_service_backend" "ngwaf_edge_service_backend_sync" {
  site_short_name = var.NGWAF_SITE
  fastly_sid      = fastly_service_vcl.frontend-vcl-service.id
  fastly_service_vcl_active_version = fastly_service_vcl.frontend-vcl-service.active_version
  depends_on = [
    sigsci_edge_deployment_service.ngwaf_edge_service_link,
  ]
}
#### NGWAF Edge deploy - End
output "love_laugh_live_ngwaf" {
  value = <<tfmultiline
  #### Click the URL to go to the service ####
  https://cfg.fastly.com/${fastly_service_vcl.frontend-vcl-service.id}
  #### Send a test request with curl. ####
  curl -i "https://${var.USER_VCL_SERVICE_DOMAIN_NAME}/anything/whydopirates?likeurls=theargs" -d foo=bar
  #### Send an test as cmd exe request with curl. ####
  curl -i "https://${var.USER_VCL_SERVICE_DOMAIN_NAME}/anything/myattackreq?i=../../../../etc/passwd'" -d foo=bar
  #### Troubleshoot the logging configuration if necessary. ####
  curl https://api.fastly.com/service/${fastly_service_vcl.frontend-vcl-service.id}/logging_status -H fastly-key:$FASTLY_API_KEY
  tfmultiline
 description = "Output hints on what to do next."
 depends_on = [
   sigsci_edge_deployment_service.ngwaf_edge_service_link
 ]
}