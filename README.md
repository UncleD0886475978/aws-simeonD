@@ -0,0 +1,66 @@
# AWS RDS Task List for Students

This README outlines tasks for working with **Amazon RDS**, including database creation, EC2 connectivity, and configuring read replicas.

---

## ✅ RDS Tasks to Perform

1. **Create an Amazon RDS Instance**
   - Choose MySQL or PostgreSQL engine
   - Select Free Tier eligible configuration (e.g., db.t3.micro)
   - Set master username and password
   - Choose a custom VPC and subnet group (if applicable)
   - Enable public access (for test purposes only)

2. **Create a Security Group for RDS**
   - Allow inbound traffic on the database port (3306 for MySQL, 5432 for PostgreSQL)
   - Restrict access to only your EC2 security group

3. **Launch an EC2 Instance in the Same VPC**
   - Use Amazon Linux 2
   - Attach a security group that allows outbound access to the RDS instance

4. **Connect to the RDS Instance from EC2**
   - Install MySQL/PostgreSQL client on EC2:
     ```bash
     # For MySQL:
     sudo yum install -y mysql

     # For PostgreSQL:
     sudo amazon-linux-extras enable postgresql14
     sudo yum install -y postgresql
     ```
   - Connect to the RDS instance using the endpoint:
     ```bash
     # For MySQL:
     mysql -h <RDS-ENDPOINT> -u <USERNAME> -p

     # For PostgreSQL:
     psql -h <RDS-ENDPOINT> -U <USERNAME> -d <DBNAME>
     ```

5. **Create a Database and Table**
   - Log in and create a sample database and table
   - Insert some sample data

6. **Create a Read Replica of the RDS Instance**
   - Use the AWS Console to create a replica
   - Choose a different AZ or region (optional)

7. **Connect to the Read Replica from EC2**
   - Use the replica’s endpoint to test read-only access
   - Attempt to read and write data to verify permissions

8. **Monitor RDS and Replica Status**
   - Use the RDS dashboard to view replication lag and performance

9. **Clean Up Resources**
   - Terminate EC2 instance
   - Delete RDS primary and read replica instances
   - Delete associated security groups

---

> 📌 Submit screenshots for RDS creation, EC2-to-RDS connection, read replica setup, and query output to validate task completion.
