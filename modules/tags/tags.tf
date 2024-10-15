# modules/tags/variables.tf

output "tags" {
  value = {
    # Mandatory
    Owner       = var.owner
    Discipline  = var.discipline
    Purpose     = var.purpose
    # Project specific
    Project     = var.project
    # Optional
    Nickname    = var.nickname
    Deploy      = var.deploy
  }
}
