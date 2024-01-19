resource "sigsci_site_list" "ofac" {
  site_short_name = var.sigsci_site
  name            = "OFAC Countries"
  type            = "country"
  description     = "Countries in the OFAC List"
  entries = [
    "SY",
    "BY",
    "MM",
    "KP",
    "IQ",
    "CD",
    "SD",
    "IR",
    "LR",
    "ZW",
    "CU",
    "CI",
  ]
}

resource "sigsci_site_list" "bad-user-agents" {
  site_short_name = var.sigsci_site
  name            = "Bad User Agents"
  type            = "wildcard"
  description     = "Anomalous User Agents"
  entries = [
    "curl*",
    "*python*",
    "*wpscan*",
    "*nmap*",
    "*masscan",
  ]
}

resource "sigsci_site_list" "attack-signals" {
  site_short_name = var.sigsci_site
  name            = "Attack Signals"
  type            = "signal"
  description     = "OWASP Attack Signals"
  entries = [
    "USERAGENT",
    "BACKDOOR",
    "CMDEXE",
    "LOG4J-JNDI",
    "SQLI",
    "TRAVERSAL",
    "XSS"
  ]
}