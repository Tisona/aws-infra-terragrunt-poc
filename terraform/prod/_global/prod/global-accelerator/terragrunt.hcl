locals {
  name = "poc-project-ga"
}

include {
  path = "../../../../modules/global-accelerator/ga.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "app-eu-central-1" {
  config_path = "../../../eu-central-1/prod/app"
}

dependency "app-us-east-2" {
  config_path = "../../../us-east-2/prod/app"
}

inputs = {
  name = local.name

  flow_logs_enabled   = false
  
  listeners = {
    listener_1 = {
      # client_affinity = "SOURCE_IP"

      endpoint_group = {
        endpoint_group_region = "eu-central-1"
        health_check_port             = 80
        health_check_protocol         = "HTTP"
        health_check_path             = "/"
        health_check_interval_seconds = 10
        health_check_timeout_seconds  = 5
        healthy_threshold_count       = 2
        unhealthy_threshold_count     = 2
        traffic_dial_percentage       = 100

        endpoint_configuration = [{
          # client_ip_preservation_enabled = true
          endpoint_id                    = dependency.app-eu-central-1.outputs.load_balancer_arn
          weight                         = 100
          }]
      }
      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    },
    listener_2 = {
      endpoint_group = {
        endpoint_group_region = "us-east-2"
        health_check_port             = 80
        health_check_protocol         = "HTTP"
        health_check_path             = "/"
        health_check_interval_seconds = 10
        health_check_timeout_seconds  = 5
        healthy_threshold_count       = 2
        unhealthy_threshold_count     = 2
        traffic_dial_percentage       = 100

        endpoint_configuration = [{
          endpoint_id                    = dependency.app-us-east-2.outputs.load_balancer_arn
          weight                         = 100
          }]
      }
      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    }
  }
}
