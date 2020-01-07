
provider "bigip" {
  address = "https://${var.address}"
  username = "admin"
  password = "${var.password}"
}