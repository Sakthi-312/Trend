output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins_ec2.public_ip
}

output "jenkins_url" {
  description = "Jenkins Web URL"
  value       = "http://${aws_instance.jenkins_ec2.public_ip}:8080"
}
