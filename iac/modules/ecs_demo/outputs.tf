#------------------------------------------------------------------------------
# ec2.tf
#------------------------------------------------------------------------------

resource "aws_ssm_parameter" "ecs_demo_task_role_arn" {
  name  = "${local.output_prefix}/ecs_demo_task/role_arn"
  type  = "String"
  value = aws_iam_role.ecs_demo_task_role.arn
  tags  = local.tags
}

output "ecs_demo_task_role_arn" {
  value = aws_iam_role.ecs_demo_task_role.arn
}
