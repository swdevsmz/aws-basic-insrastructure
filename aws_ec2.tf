# ---------------------------
# EC2
# ---------------------------
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# キーペア
# 変数で指定した値を設定
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file("${var.key_name}.pub")
}


resource "aws_instance" "amazonlinux" {
  ami                    = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id              = aws_subnet.public.id

  key_name = aws_key_pair.main.key_name

  tags = {
    Name = var.name
  }
}