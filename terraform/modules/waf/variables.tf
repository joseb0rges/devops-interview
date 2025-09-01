variable "name" {
  description = "Nome do Web ACL."
  type        = string
}

variable "scope" {
  description = "REGIONAL (ALB/APIGW/AppSync) ou CLOUDFRONT."
  type        = string
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope deve ser REGIONAL ou CLOUDFRONT."
  }
}

variable "description" {
  description = "Descrição opcional."
  type        = string
  default     = "Minimal AWS WAFv2 Web ACL"
}

variable "default_action" {
  description = "Ação padrão (ALLOW/BLOCK)."
  type        = string
  default     = "ALLOW"
  validation {
    condition     = contains(["ALLOW", "BLOCK"], var.default_action)
    error_message = "default_action deve ser ALLOW ou BLOCK."
  }
}

variable "associate_resource_arns" {
  description = "Map of resource ARNs to associate (use static keys, e.g., alb)."
  type        = map(string)
  default     = {}
}


variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = {}
}

variable "managed_rule_groups" {
  description = "Conjunto de AWS Managed Rule Groups."
  type = list(object({
    name     = string
    vendor   = string
    priority = number
  }))
  default = []
}

# já existente
variable "custom_rules" {
  description = "Regras customizadas."
  type = list(object({
    name       = string
    priority   = number
    action     = string              # BLOCK | ALLOW | COUNT
    type       = string              # byte_match_any | sqli_match | sqli_full_scan | geo_match
    # byte_match_any
    match_field        = optional(string)      # uri_path | query_string | body | single_header
    header_name        = optional(string)
    search_strings     = optional(list(string), [])
    text_transform     = optional(string, "NONE")
    # sqli_match
    sqli_field         = optional(string)      # query_string | body | single_header
    sqli_header_name   = optional(string)
    # sqli_full_scan (OR de vários campos)
    # (sem campos adicionais)
    # geo_match
    country_codes      = optional(list(string), [])
  }))
  default = []
}

# renomeio/controle da rate-limit (para virar "RateLimitExceeded" na prioridade 3)
variable "rate_limit_name" {
  type        = string
  default     = "RateLimitExceeded"
}
variable "rate_limit" {
  description = "Limite (req/5min por IP). 0=desliga"
  type        = number
  default     = 0
}
variable "rate_limit_priority" {
  type        = number
  default     = 95
  description = "Prioridade da regra de rate-limit."
}
