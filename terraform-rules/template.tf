resource "sigsci_site_rule" "testsignal" {
  site_short_name = var.sigsci_site
  type            = "templatedSignal"
  group_operator  = "all"
  enabled         = true
  reason          = "Example site rule update"
  signal          = "PW-RESET-ATTEMPT"
  expiration      = ""

  conditions {
    type     = "single"
    field    = "method"
    operator = "equals"
    value    = "POST"
  }

  conditions {
    type     = "single"
    field    = "path"
    operator = "equals"
    value    = "/change-password"
  }

}