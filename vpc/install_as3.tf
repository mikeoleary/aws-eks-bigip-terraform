
# download rpm
resource "null_resource" "download_as3" {
  provisioner "local-exec" {
    command = "wget ${var.as3_rpm_url} -O ${var.as3_rpm}"
  }
}

# install rpm to BIG-IP. Wait 3 mins after f5 has been provisioned, then install. 
resource "null_resource" "install_as3" {
  provisioner "local-exec" {
    command = "sleep 180 && ./install_as3.sh ${aws_instance.f5.public_ip}:443 admin:${random_password.password.result} ${var.as3_rpm}"
    working_dir = "${path.module}"
  }
  depends_on = [
    "null_resource.download_as3",
    "aws_instance.f5"
    ]
}

