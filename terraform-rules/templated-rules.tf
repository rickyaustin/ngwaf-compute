resource "sigsci_site_templated_rule" "login_attempt" {
  site_short_name = var.sigsci_site
  name            = "LOGINATTEMPT"
  detections {
    enabled = "true"
    fields {
      name  = "path"
      value = "/login"
    }
  }

  alerts {
    long_name              = "alert 1"
    interval               = 10
    threshold              = 10
    skip_notifications     = true
    enabled                = true
    action                 = "template"
    block_duration_seconds = 64000
  }

  alerts {
    long_name              = "alert 2"
    interval               = 1
    threshold              = 10
    skip_notifications     = false
    enabled                = true
    action                 = "template"
    block_duration_seconds = 64000
  }
}


resource "sigsci_site_templated_rule" "login_failure" {
  site_short_name = var.sigsci_site
  name            = "LOGINFAILURE"
  detections {
    enabled = "true"
    fields {
      name  = "path"
      value = "/login"
    }
    fields {
        name = "responseCode"
        value = 401
    }
  }
  alerts {
    long_name              = "alert 1"
    interval               = 10
    threshold              = 10
    skip_notifications     = true
    enabled                = true
    action                 = "template"
    block_duration_seconds = 64000
  }

  alerts {
    long_name              = "alert 2"
    interval               = 1
    threshold              = 10
    skip_notifications     = false
    enabled                = true
    action                 = "template"
    block_duration_seconds = 64000
  }
}

resource "sigsci_site_templated_rule" "login_success" {
  site_short_name = var.sigsci_site
  name            = "LOGINSUCCESS"
  detections {
    enabled = "true"
    fields {
      name  = "path"
      value = "/login"
    }
    fields {
        name = "responseCode"
        value = 302
    }
  }
}