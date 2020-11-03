/*

# Purpose

TODO

# Usage

TODO

# References

[1] https://github.com/QuiNovas/terraform-aws-batch-compute-environment/blob/master/main.tf

*/

data "aws_availability_zones" "available" {
  state = "available"
}

module "batch_compute_environment" {

  # TODO: Expose the options below as variables.
  # TODO: Expose outputs.
  # TODO: https://github.com/QuiNovas/terraform-aws-batch-compute-environment/issues/8

  source = "QuiNovas/batch-compute-environment/aws"

  name                   = "statistics-flanders"
  type                   = "MANAGED"
  compute_resources_type = "SPOT"
  instance_type          = ["optimal"]  # Represents a collection of m, c, r instances.
  bid_percentage         = 115
  min_vcpus              = 0
  desired_vcpus          = 0
  max_vcpus              = 16

  availability_zones     = data.aws_availability_zones.available.names
  cidr_block             = "10.0.0.0/16"

}
