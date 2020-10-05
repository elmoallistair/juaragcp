# [Migrate a MySQL Database to Google Cloud SQL](https://www.qwiklabs.com/focuses/1740?parent=catalog)

## Overview

For this Challenge Lab you must complete a series of tasks within a limited time period. Instead of following step-by-step instructions, you'll be given a scenario and task - you figure out how to to complete it on your own! An automated scoring system (shown on this page) will provide feedback on whether you have completed your tasks correctly.

## Challenge Scenario

Your WordPress blog is running on a server that is no longer suitable. As the first part of a complete migration exercise, you are migrating the locally hosted database used by the blog to Cloud SQL.

The existing WordPress installation is installed in the `/var/www/html/wordpress` directory in the instance called `blog` that is already running in the lab. You can access the blog by opening a web browser and pointing to the external IP address of the blog instance.

The existing database for the blog is provided by MySQL running on the same server. The existing MySQL database is called `wordpress` and the user called __blogadmin__ with password __Password1*__ , which provides full access to that database.