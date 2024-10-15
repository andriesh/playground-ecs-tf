resource "aws_ecr_repository" "random-quotes" {
    name            = "andrei-rusnac-ecr"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
      scan_on_push = true
    }
    tags = module.common_tags.tags
}
output "repository_url" {
  description = "The URL of the repository."
  value = aws_ecr_repository.random-quotes.repository_url
}