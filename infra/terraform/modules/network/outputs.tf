output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "higuchi_pr_ecs_sg_id" {
  value = aws_security_group.higuchi_pr_ecs_sg.id
}
output "higuchi_pr_alb_sg_id" {
  value = aws_security_group.higuchi_pr_alb_sg.id
}
