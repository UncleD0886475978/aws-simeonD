@@ -0,0 +1,72 @@
# AWS IAM Task List

This README outlines tasks related to **AWS Identity and Access Management (IAM)**, including user management, policy assignment, and programmatic access using access keys.

---

## ✅ IAM Tasks to Perform

1. **Create an IAM User**
   - Set AWS Management Console access
   - Assign a password and require a password reset on first login

2. **Assign a Role or Policy to the User**
   - Attach predefined policies (e.g., `AmazonS3ReadOnlyAccess`, `EC2FullAccess`)
   - Optionally create and attach a custom policy

3. **Login as IAM User**
   - Use the user-specific login URL
   - Perform basic tasks in the console to test assigned permissions

4. **Reset or Expire IAM User Password**
   - Force a password change or manually reset it as the admin

5. **Create Access Key and Secret Access Key for the User**
   - Enable programmatic access
   - Download and securely store the keys

6. **Install AWS CLI on Local Machine**
   - Configure CLI with IAM user credentials
   - Test CLI access (e.g., list S3 buckets or EC2 instances)

7. **Use IAM Access Keys in a Python Script**
   - Write a Python script using `boto3` to interact with AWS services (e.g., list S3 buckets)

8. **Delete Access Keys (Optional)**
   - Rotate or revoke keys to maintain security

9. **Clean Up Resources**
   - Remove users, roles, and policies created during the task

---

## 🐍 Sample Python Script Using IAM Access Keys

```python
import boto3

# Replace with your IAM access key and secret key
aws_access_key = 'YOUR_ACCESS_KEY'
aws_secret_key = 'YOUR_SECRET_KEY'

# Initialize S3 client
s3 = boto3.client(
    's3',
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key,
    region_name='us-east-1'
)

# List S3 buckets
response = s3.list_buckets()
print("S3 Buckets:")
for bucket in response['Buckets']:
    print(f"  - {bucket['Name']}")
```

> ⚠️ Replace the placeholder keys with your actual IAM credentials. Do not commit or share your keys publicly.

---

> 📌 Submit screenshots for user creation, login attempt, password change, CLI access, and Python script output to validate task completion.
