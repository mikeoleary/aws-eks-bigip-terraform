
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
/*
# deploy application using as3
resource "bigip_as3" "helloworld" {
  as3_json    = "${file("../as3/helloworld.json")}"
  config_name = "app1"
  depends_on  = [null_resource.install_as3]
}
*/
