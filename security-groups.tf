# security group
resource "aws_security_group" "alb" {
	name = "alb-security-group"
	description = "alb security group"
	vpc_id = "${aws_vpc.2048.id}"
	
	ingress {
		from_port = 0
		to_port = 80
		protocol = "tcp"
		#self = true
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		#self = true
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	tags {
		Name = "alb-security-group"
	}
}



resource "aws_security_group" "node" {
	name = "node-security-group"
	description = "node security group"
	vpc_id = "${aws_vpc.2048.id}"
	
	ingress {
		from_port = 0
		to_port = 80
		protocol = "tcp"
		#self = true
		#cidr_blocks = ["0.0.0.0/0"]
		security_groups = ["${aws_security_group.alb.id}"]
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		#self = true
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	tags {
		Name = "node-security-group"
	}
}

/*
resource "aws_security_group" "node" {
	name = "node-security-group"
	description = "node security group"
	vpc_id = "${aws_vpc.2048.id}"
	
	ingress {
		from_port = 0
		to_port = 80
		protocol = "tcp"
		#self = true
		#cidr_blocks = ["0.0.0.0/0"]
		security_groups = ["${aws_security_group.alb.id}"]
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		#security_groups = ["${aws_security_group.alb.id}"]
	}
	
	tags {
		Name = "node-security-group"
	}
}
*/

