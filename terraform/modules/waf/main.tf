locals {
  default_action_block = var.default_action == "BLOCK"
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope

  # Ação padrão
  default_action {
    dynamic "allow" {
      for_each = local.default_action_block ? [] : [1]
      content {}
    }
    dynamic "block" {
      for_each = local.default_action_block ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-metrics"
    sampled_requests_enabled   = true
  }

  
  # Regras CUSTOM 

  dynamic "rule" {
    # usar prioridade como chave evita colisões
    for_each = { for r in var.custom_rules : r.priority => r }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # Ações (cada uma no próprio bloco) — EXPANDIDO
      dynamic "action" {
        for_each = rule.value.action == "BLOCK" ? [1] : []
        content {
          block {}
        }
      }
      dynamic "action" {
        for_each = rule.value.action == "ALLOW" ? [1] : []
        content {
          allow {}
        }
      }
      dynamic "action" {
        for_each = rule.value.action == "COUNT" ? [1] : []
        content {
          count {}
        }
      }

      statement {

        # byte_match_any:
        # - se houver 2+ termos => OR de vários byte_match_statement

        dynamic "or_statement" {
          for_each = rule.value.type == "byte_match_any" && length(try(rule.value.search_strings, [])) > 1 ? [1] : []
          content {
            dynamic "statement" {
              for_each = rule.value.search_strings
              content {
                byte_match_statement {
                  search_string         = statement.value
                  positional_constraint = "CONTAINS"

                  dynamic "field_to_match" {
                    for_each = [1]
                    content {
                      dynamic "uri_path" {
                        for_each = rule.value.match_field == "uri_path" ? [1] : []
                        content {}
                      }
                      dynamic "query_string" {
                        for_each = rule.value.match_field == "query_string" ? [1] : []
                        content {}
                      }
                      dynamic "body" {
                        for_each = rule.value.match_field == "body" ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = rule.value.match_field == "single_header" ? [1] : []
                        content {
                          name = lower(rule.value.header_name)
                        }
                      }
                    }
                  }

                  text_transformation {
                    priority = 0
                    type     = try(rule.value.text_transform, "NONE")
                  }
                }
              }
            }
          }
        }

        # byte_match_any com 1 único termo => um único byte_match_statement
        dynamic "byte_match_statement" {
          for_each = (rule.value.type == "byte_match_any" && length(try(rule.value.search_strings, [])) == 1) ? [element(rule.value.search_strings, 0)] : []
          content {
            search_string         = byte_match_statement.value
            positional_constraint = "CONTAINS"

            dynamic "field_to_match" {
              for_each = [1]
              content {
                dynamic "uri_path" {
                  for_each = rule.value.match_field == "uri_path" ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = rule.value.match_field == "query_string" ? [1] : []
                  content {}
                }
                dynamic "body" {
                  for_each = rule.value.match_field == "body" ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = rule.value.match_field == "single_header" ? [1] : []
                  content {
                    name = lower(rule.value.header_name)
                  }
                }
              }
            }

            text_transformation {
              priority = 0
              type     = try(rule.value.text_transform, "NONE")
            }
          }
        }

        # sqli_match (1 campo)
        dynamic "sqli_match_statement" {
          for_each = rule.value.type == "sqli_match" ? [1] : []
          content {
            dynamic "field_to_match" {
              for_each = [1]
              content {
                dynamic "query_string" {
                  for_each = rule.value.sqli_field == "query_string" ? [1] : []
                  content {}
                }
                dynamic "body" {
                  for_each = rule.value.sqli_field == "body" ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = rule.value.sqli_field == "single_header" ? [1] : []
                  content {
                    name = lower(coalesce(rule.value.sqli_header_name, "host"))
                  }
                }
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }

        # sqli_full_scan (OR em vários campos) — EXPANDIDO
        dynamic "or_statement" {
          for_each = rule.value.type == "sqli_full_scan" ? [1] : []
          content {

            statement {
              sqli_match_statement {
                field_to_match {
                  all_query_arguments {}
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }

            statement {
              sqli_match_statement {
                field_to_match {
                  query_string {}
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }

            statement {
              sqli_match_statement {
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }

            statement {
              sqli_match_statement {
                field_to_match {
                  body {
                    oversize_handling = "CONTINUE"
                  }
                }
                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }

        # geo_match
        dynamic "geo_match_statement" {
          for_each = rule.value.type == "geo_match" ? [1] : []
          content {
            country_codes = rule.value.country_codes
          }
        }
      } # statement

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "custom-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Managed Rule Groups (opcionais)
  
  dynamic "rule" {
    for_each = var.managed_rule_groups
    content {
      name     = "${rule.value.vendor}-${rule.value.name}"
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "mrg-${rule.value.vendor}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate limit (opcional)
  dynamic "rule" {
    for_each = var.rate_limit > 0 ? [1] : []
    content {
      name     = var.rate_limit_name       # ex.: "RateLimitExceeded"
      priority = var.rate_limit_priority   # ex.: 3
      action {
        block {}
      }
      statement {
        rate_based_statement {
          aggregate_key_type = "IP"
          limit              = var.rate_limit
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = var.rate_limit_name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = var.tags
}


resource "aws_wafv2_web_acl_association" "assoc" {
  # usando map(string); chaves estáticas garantem estabilidade no plan
  for_each     = var.scope == "REGIONAL" ? var.associate_resource_arns : {}
  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
