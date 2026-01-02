@@ -0,0 +1,48 @@
# AWS Load Balancer Task List for Students

This README outlines the tasks to set up an **Application Load Balancer (ALB)** in a **single VPC** with EC2 instances in multiple subnets.

---

## ✅ Load Balancer Tasks to Perform

1. **Create a Custom VPC**
   - CIDR block: `10.0.0.0/16`

2. **Create Two Public Subnets**
   - Subnet A: `10.0.1.0/24` in AZ1
   - Subnet B: `10.0.2.0/24` in AZ2

3. **Launch EC2 Instances in Each Subnet**
   - Use Amazon Linux 2
   - Install a simple web server (e.g., return different HTML message per instance)

4. **Create a Security Group for EC2 Instances**
   - Allow HTTP (80) from anywhere
   - Allow inbound traffic from the ALB security group (to be created)

5. **Create an Internet Gateway and Attach to VPC**

6. **Create and Associate Route Tables**
   - Ensure both subnets have routes to the internet via the IGW

7. **Create a Target Group**
   - Target type: instance
   - Protocol: HTTP, port 80
   - Register both EC2 instances

8. **Create a Security Group for the Load Balancer**
   - Allow inbound HTTP (port 80) from anywhere

9. **Create an Application Load Balancer (ALB)**
   - Choose internet-facing
   - Select both public subnets (A & B)
   - Attach the previously created security group
   - Link the ALB to the created target group

10. **Test Load Balancer Endpoint**
   - Copy the DNS name of the ALB
   - Access it via browser and ensure both instances respond (via round-robin)

11. **Clean Up Resources**
   - Delete the ALB, target group, EC2 instances,
