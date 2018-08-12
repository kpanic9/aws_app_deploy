# user data script 
data "template_file" "init" {
  template = "${file("./app-config.sh.tpl")}"
}




# launch config
resource "aws_launch_configuration" "conf" {
	name_prefix   = "app-config-"
	image_id      = "ami-e0ba5c83"
	instance_type = "t2.micro"
	
	security_groups = ["${aws_security_group.node.id}"]
	user_data = "${data.template_file.init.rendered}"
  
	lifecycle {
		create_before_destroy = true
	}
}



# auto scaling group
resource "aws_autoscaling_group" "app" {
	name                 = "app"
	launch_configuration = "${aws_launch_configuration.conf.name}"
	min_size             = 2
	max_size             = 5
  
	target_group_arns = ["${aws_alb_target_group.alb-target-group.arn}"]
	vpc_zone_identifier = [
			"${aws_subnet.2048-private-1.id}", 
			"${aws_subnet.2048-private-2.id}"
	]

	lifecycle {
		create_before_destroy = true
	}
}



# scaling policy
resource "aws_autoscaling_policy" "cpu-scale-up" {
	name = "cpu-scale-up"
	autoscaling_group_name = "${aws_autoscaling_group.app.name}"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "1"
	cooldown = "300"
	policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-scale-up" {
	alarm_name = "cpu-scale-up"
	alarm_description = "cpu-scale-up"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = "2"
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = "120"
	statistic = "Average"
	threshold = "60"
	dimensions = {
		"AutoScalingGroupName" = "${aws_autoscaling_group.app.name}"
	}
	actions_enabled = true
	alarm_actions = ["${aws_autoscaling_policy.cpu-scale-up.arn}"]
}



# application load balancer
resource "aws_alb" "alb" {
	name = "2048-alb"
	internal = false
	security_groups	= ["${aws_security_group.alb.id}"]
	subnets	= [
			"${aws_subnet.2048-public-1.id}", 
			"${aws_subnet.2048-public-2.id}"
		]
}

resource "aws_alb_listener" "alb-listener" {
	load_balancer_arn	=	"${aws_alb.alb.arn}"
	port = "80"
	protocol = "HTTP"
	default_action {
		target_group_arn = "${aws_alb_target_group.alb-target-group.arn}"
		type = "forward"
	}
}



# target group
resource "aws_alb_target_group" "alb-target-group" {
	name = "2048-alb-target-group"
	vpc_id = "${aws_vpc.2048.id}"
	port = "80"
	protocol = "HTTP"
	health_check {
                path = "/"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 2
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200-308"
        }
}

