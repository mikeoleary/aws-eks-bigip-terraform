
# download rpm
resource "null_resource" "download_as3" {
  provisioner "local-exec" {
    command = "wget ${var.as3_rpm_url} -O ${var.as3_rpm}"
  }
}

# install rpm to BIG-IP
resource "null_resource" "install_as3" {
  provisioner "local-exec" {
    command = "./install_as3.sh ${var.address}:443 admin:${var.password} ${var.as3_rpm}"
    working_dir = "${path.module}"
  }
  depends_on = ["null_resource.download_as3"]
}

