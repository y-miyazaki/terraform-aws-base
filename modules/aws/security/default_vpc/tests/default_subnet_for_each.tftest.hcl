mock_provider "aws" {}

override_data {
  target = data.aws_vpcs.default[0]
  values = {
    ids = ["vpc-00000000"]
  }
}

override_data {
  target = data.aws_availability_zones.this
  values = {
    names = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  }
}

variables {
  is_enabled_flow_logs = false
  region               = "ap-northeast-1"
}

run "subnets_keyed_by_availability_zone" {
  command = plan

  assert {
    condition     = toset(keys(aws_default_subnet.this)) == toset(["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"])
    error_message = "aws_default_subnet must be keyed by availability zone name"
  }

  assert {
    condition     = alltrue([for az, s in aws_default_subnet.this : s.availability_zone == az && s.map_public_ip_on_launch == false])
    error_message = "Each subnet must target its key AZ and keep map_public_ip_on_launch disabled"
  }
}

run "disabled_creates_nothing" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_default_subnet.this) == 0
    error_message = "No subnets must be managed when is_enabled is false"
  }
}
