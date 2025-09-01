locals {
  # Managed AWS – comece em 20 para não colidir com as custom (3..8)
  waf_managed_default = [
    { name = "AWSManagedRulesKnownBadInputsRuleSet", vendor = "AWS", priority = 20 },
    { name = "AWSManagedRulesPHPRuleSet",            vendor = "AWS", priority = 30 },
    { name = "AWSManagedRulesLinuxRuleSet",          vendor = "AWS", priority = 40 },
  ]

  # CUSTOM defaults (3..8)
  waf_custom_default = [
    # 4) DDoSSlowHttpTestBlock (referer contém "slowhttptest")
    {
      name          = "DDoSSlowHttpTestBlock"
      priority      = 4
      action        = "BLOCK"
      type          = "byte_match_any"
      match_field   = "single_header"
      header_name   = "referer"
      search_strings= ["slowhttptest"]
      text_transform= "NONE"
    },

    # 5) SQLInjectionByHeaderHostBlock (SQLi no header Host)
    {
      name            = "SQLInjectionByHeaderHostBlock"
      priority        = 5
      action          = "BLOCK"
      type            = "sqli_match"
      sqli_field      = "single_header"
      sqli_header_name= "host"
    },

    # 6) SuspiciousRequestForProtectedResources (path contém extensões/sinais)
    {
      name          = "SuspiciousRequestForProtectedResources"
      priority      = 6
      action        = "BLOCK"
      type          = "byte_match_any"
      match_field   = "uri_path"
      search_strings= [".env", "vendor/", "/.", ".sql"]
      text_transform= "NONE"
    },

    # 7) SQLInjectionFullScanCount (OR em vários campos)
    {
      name     = "SQLInjectionFullScanCount"
      priority = 7
      action   = "BLOCK"
      type     = "sqli_full_scan"
    },

    # 8) SuspiciousRequestFromUnexpectedCountries (geo-match RU, CN, IN, KR)
    {
      name          = "SuspiciousRequestFromUnexpectedCountries"
      priority      = 8
      action        = "BLOCK"
      type          = "geo_match"
      country_codes = ["RU","CN","IN","KR"]
    }
  ]

  # RateLimit default (3)
  waf_rate_limit_name      = "RateLimitExceeded"
  waf_rate_limit_value     = 1000
  waf_rate_limit_priority  = 3
}

output "waf_managed_default"        { value = local.waf_managed_default }
output "waf_custom_default"         { value = local.waf_custom_default }
output "waf_rate_limit_name"        { value = local.waf_rate_limit_name }
output "waf_rate_limit_value"       { value = local.waf_rate_limit_value }
output "waf_rate_limit_priority"    { value = local.waf_rate_limit_priority }
