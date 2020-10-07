# Migrate a MySQL Database to Google Cloud SQL
# https://www.qwiklabs.com/focuses/1740?parent=catalog

# Task 1: Check that there is a Cloud SQL instance
  - Go to SQL -> Create Instance -> MySQL -> fill the name with "lab" and fill the password
    It will take a several times to create the instance, you can go to Task 2 without waiting here

# Task 2: Check that there is a user database on the Cloud SQL instance
  - Go to Compute Engine, click SSH button on "blog" instance
  - run mysqldump --databases wordpress -h localhost -u blogadmin -p --hex-blob --skip-triggers --single-transaction --default-character-set=utf8mb4 > wordpress.sql
    - Enter the password with Password1*
    - run export PROJECT_ID=$(gcloud info --format='value(config.project)')
    - run gsutil mb gs://${PROJECT_ID}
    - run gsutil cp ~/wordpress.sql gs://${PROJECT_ID}
  - Back to Cloud Console -> SQL -> lab -> Databases -> Create Database
    - Fill the database name with wordpress and on character set, choose utf8mb4 then click Create
  - Click Overview -> Import -> Browse -> Select wordpress.sql from your bucket -> Select -> Import
  - Check Your Progress

# Task 3: Check that the blog instance is authorized to access Cloud SQL
  - On left panel, click Users -> Add User Account
    - Fill the name field with blogadmin and password field with Password1* -> add
  - On the left pannel, Click Connections
    - Click Add Network Under the Authorized networks
    - Fill the name with blog
    - Fill the Network with IP Address from Demo Blog Site Field, Change the latest part of the IP address with 0 and add /24 ( example: If IP = 34.123.155.123, fill with 34.123.155.0/24 )
    - Check Your Progress

# Task 4: Check that wp-config.php points to the Cloud SQL instance
  - Go to SQL -> Copy the Public IP Address from lab SQL instance
  - Go to VM Instances click SSH Shell at "blog"
    - run cd /var/www/html/wordpress/
    - run sudo nano wp-config.php
    - Change localhost string on DB_HOST with Public IP Address of SQL Instance that has copied before
    - Check Your Progress

# Task 5: Check that the blog still responds to requests
  - Now You can open your Demo Blog Site in the new tab and verify that no error
  - Check Your Progress
