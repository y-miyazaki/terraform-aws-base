#--------------------------------------------------------------
# For Compute Optimizer
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an Compute Optimizer.
#--------------------------------------------------------------
module "aws_recipes_compute_optimizer" {
  source     = "../../modules/aws/recipes/compute_optimizer"
  is_enabled = lookup(var.compute_optimizer, "is_enabled", true)
}
