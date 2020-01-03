
provider "bigip" {
  address = "https://${var.address}:8443"
  username = "admin"
  password = "${var.password}"
}