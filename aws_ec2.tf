resource "aws_instance" "hello-world" {
    ami = "ami-0218d08a1f9dac831"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.publics[0].id

    tags = {
        Name = var.name
    }
}