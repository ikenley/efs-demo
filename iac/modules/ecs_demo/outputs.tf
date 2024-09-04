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

resource "aws_ssm_parameter" "ecs_demo_task_security_group_arn" {
  name  = "${local.output_prefix}/ecs_demo_task/security_group_arn"
  type  = "String"
  value = aws_security_group.ecs_demo_task.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "ecs_demo_task_security_group_id" {
  name  = "${local.output_prefix}/ecs_demo_task/security_group_id"
  type  = "String"
  value = aws_security_group.ecs_demo_task.id
  tags  = local.tags
}
