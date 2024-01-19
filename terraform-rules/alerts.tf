resource "sigsci_site_alert" "owasp-threshold-1" {
  site_short_name    = var.sigsci_site
  tag_name           = "site.attack-signal"
  long_name          = "OWASP 10 1 Threshold"
  interval           = 1
  threshold          = 10
  enabled            = true
  action             = "flagged"
  skip_notifications = true
  depends_on = [
    sigsci_site_signal_tag.attack-signal
  ]
}

resource "sigsci_site_alert" "owasp-threshold-2" {
  site_short_name    = var.sigsci_site
  tag_name           = "site.attack-signal"
  long_name          = "OWASP 10 10 Threshold"
  interval           = 10
  threshold          = 10
  enabled            = true
  action             = "flagged"
  skip_notifications = true
  depends_on = [
    sigsci_site_signal_tag.attack-signal
  ]
}


resource "sigsci_site_alert" "owasp-threshold-3" {
  site_short_name    = var.sigsci_site
  tag_name           = "site.attack-signal"
  long_name          = "OWASP 10 60 Threshold"
  interval           = 60
  threshold          = 10
  enabled            = true
  action             = "flagged"
  skip_notifications = true
  depends_on = [
    sigsci_site_signal_tag.attack-signal
  ]
}