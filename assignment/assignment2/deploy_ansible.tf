resource "aws_instance" "example" {
  ami           = "${var.ami-mine}"
  instance_type = "t2.micro"
  key_name      = "rahul"

  tags = {
    Name = "ANSIBLE"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = "${self.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install ansible2 -y",
      "sudo yum install git -y",
      "git clone https://github.com/ /tmp/ans_ws",
      "ansible-playbook ./assignment2/deploy.yaml"
    ]
  }
}