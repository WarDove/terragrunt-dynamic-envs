data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}


/*

TODO: implement AWS ALB Controller
TODO: implement external secrets
TODO: implement external dns
TODO: Implement imitation of dynamic Enviironments

*/