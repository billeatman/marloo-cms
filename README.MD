Marloo CMS

============================================

Note:  This project is very very alpha and probably won't be of use to you yet.  If you want to dev, contact me at billeatman@hotmail.com.

Setting up Marloo

I'm assuming Commandbox(Lucee) and MSSQL

Database:

Create a new database in MS SQL named marloo-cms

Open a new query and load the file setup-sql\MSSQL_create_marloo.sql.cfm
Run the script on the new database.  This will set up the initial database.

Open a new query and load the file setup-sql\MSSQL_populate_marloo.sql.cfm
Run the script on the database.  This will populate the database.

Now add the datasource in Lucee as marloo-cms.

Server:

You must start your server using commandbox with the flag --rewritesEnable for SES urls.

server start --rewritesEnable



