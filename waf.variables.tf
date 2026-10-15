variable "waf_policies" {
  description = "OCI Web Application Firewall policies keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    actions = optional(list(object({
      name = string
      type = string
      body = optional(object({
        text     = optional(string)
        type     = string
        template = optional(string)
      }))
      code = optional(number)
      headers = optional(list(object({
        name  = optional(string)
        value = optional(string)
      })), [])
    })), [])
    request_access_control = optional(object({
      default_action_name = string
      rules = optional(list(object({
        action_name        = string
        condition          = optional(string)
        condition_language = optional(string)
        name               = string
        type               = string
      })), [])
    }))
    request_rate_limiting = optional(object({
      rules = optional(list(object({
        action_name        = string
        condition          = optional(string)
        condition_language = optional(string)
        configurations = list(object({
          action_duration_in_seconds = optional(number)
          period_in_seconds          = number
          requests_limit             = number
        }))
        name = string
        type = string
      })), [])
    }))
  }))
  default = {}
}

