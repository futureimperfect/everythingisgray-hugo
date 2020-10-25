+++
date = "2010-07-21"
slug = "2010/07/21/restore-mysql-database-from-ibdata-and-frm-files"
title = "Restore MySQL Database From ibdata and .frm Files"
url = "/2010/07/21/restore-mysql-database-from-ibdata-and-frm-files/"
aliases = [
    "/2010/07/21/restore-mysql-database-from-ibdata-and-.frm-files/"
]
Categories = ["Technology", "Web Development"]
Tags = ["MySQL", "Web Development"]
+++

Last week I was presented with a problem that involved restoring a MySQL database for a client using only the `/data` folder from an original MySQL installation. The solution turned out to be rather simple, but that didn't stop me from racking my brain for a few hours. Thus, I thought I'd share my experience in hopes of helping others that may run into this.

*NOTE* The MySQL database I was tasked with restoring was associated with a WordPress installation. My guess is that this is irrelevant, though.

*ALSO NOTE* This article assumes you are comfortable with software solutions such as [MAMP](http://www.mamp.info/en/index.html) and/or [XAMPP](http://www.apachefriends.org/en/xampp.html), as well as [phpMyAdmin](http://www.phpmyadmin.net/home_page/index.php).

I made the decision early on to solve this problem locally, (I find that working directly from a web server usually just gets me into trouble).  I use MAMP on a regular basis and as such have quite a few MySQL databases associated with that installation. Rather than fooling with this at all I opted to use XAMPP on a Windows XP SP2 machine. Either one of these solutions will work, as they essentially provide the same services. I chose to avoid using MAMP on my machine because of everything I have invested into that application, but that doesn't mean you have to.

The first thing you'll want to do is install a fresh copy of either MAMP, (Mac only), or XAMPP. Then create an empty database using phpMyAdmin with the same name as your original database, (the one you're trying to restore). For example, if your previous database was called 'wordpress,' in phpMyAdmin, (under the 'Create new database' text field), you would enter 'wordpress.' This will create a folder named `wordpress` in `/Applications/MAMP/db/mysql` if you're using MAMP, or `C:\xampp\mysql` if you're using XAMPP. At this point you'll want to turn off the MySQL service. Now, copy the contents of, (not the entire folder), your mysql database folder that contains the .frm files to the new location. The next step is to copy the `ibdata1` file to the MySQL folder in either XAMPP or MAMP, then start the MySQL service again. Now you should be able to locate your database tables in phpMyAdmin.

At this point, (assuming you don't want to keep the data locally on your machine), you'll want to export the database using phpMyAdmin. Be sure to check Add DROP TABLE, choose SQL as the export type, and check the 'Save as file' checkbox. The .sql file that will be generated can easily be imported into another instance of phpMyAdmin. The new database doesn't need to have the same name as the previous database, either. I was unable to use my previous database name because the site I was working on had been moved to a shared hosting server, (where someone had already chosen the name of my previous database), and everything worked fine.

Also keep in mind that this can be accomplished whether or not your server is running phpMyAdmin. There are plenty of alternatives available that will allow you to accomplish the same tasks, and there's always the command line. The most important step is to simply copy the contents of the `/data` folder and the `ibdata1` file. Hope this helps!

Leave a comment if you have any questions!
