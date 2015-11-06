- [What is apex_oauth?](#about)
- [Documentation](#documentation)
- [Download](#download)
- [Installation](#installation)
- [HTTPD configuration](#httpd)
- [License](#license)


#about
PL/SQL packages enabling Google, Linkedin and Facebook login for apex. Apex-oauth does not rely on any tables.
There is one table (S4SA_SETTINGS) that contains some settings you must review and change to reflect your specific situation.

#documentation
To enable your apex-application to use apex_oauth you need to register yourself at the appropriate sites:
- Google: [Google developer console](https://console.developers.google.com/start)
- Facebook: [Facebook developer console](https://developers.facebook.com/apps)
- Linked-in: [Linkedin developer console](https://www.linkedin.com/developer/apps)

There you will be able to create an application. The Provider (Google, Facebook etc.) will then provide you some codes which you must put in the s4a_settings table.

#download
It is recommended that you download a certified release (from the [releases](https://github.com/smart4solutions/apex_oauth/releases) folder). The files in the current repository are for the next release and should be considered unstable.

#installation
The product consists of a number of database-objects:
- packages
- tables
- sequences
- etc...

##install into an existing application
1. as sys: login into your database and execute the "grant_as_sysdba.sql" script. It will grant execute on the sys_http package to your parsing schema
2. in apex, login into your workspace
3. within the SQL Workshop:
  - upload and execute the "apex_oauth.sql" script which will create all database objects
  - upload and execute the "s4a_settings_data.sql" script which will create the settings in the s4sa_settings table
  - execute the follwing command: grant execute on S4SG_AUTH_PCK to APEX_PUBLIC_USER
4. import the plugin into your application
5. adjust the settings in the s4sa_settings table, they should reflect the settings in your developer console
  - S4SA_GGL_API_KEY
  - S4SA_GGL_CLIENT_ID
  - S4SA_GGL_CLIENT_SECRET
  - S4SA_GGL_REDIRECT_URL
6. Go to page 101 (the login-page) of your application
  - remove the username and password items
  - rename the login-button so it reflects the value of the S4SA_GGL_LOGIN_REQUEST record in your S4SA_SETTINGS table (default GGL_LOGIN)

##install into a new application
1. Create your application
2. follow the steps in "install into an existing application"
3. continue developing your application

#httpd configuration
It is highly advisable to use a everse proxy as described in my [blog](http://richardmartens.blogspot.nl/2015/07/making-https-webservice-requests-from.html).
I have included the settings as I use them in my web-server setup. This prevents you from having to create an Oracle wallet. It also alows you to use Linked-in as the oauth provider. Since Linked-in uses a specific algorithm that is not supported below Oracle 11.2.0.3.

#license
This project is uses the [MIT license](LICENSE).
