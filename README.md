- [What is apex_oauth?](#about)
- [Documentation](#documentation)
- [Download](#download)
- [Installation](#installation)
  - [Into an existing application](#install-into-an-existing-application)
  - [Into a new application](#install-into-a-new-application)
- [HTTPD configuration](#httpd)
- [The settings table](#the-s4sa_settings-table)
- [License](#license)


#about
PL/SQL packages enabling Google, Linkedin and Facebook login for apex. Apex-oauth does not rely on any tables. There is one table (S4SA_SETTINGS) that contains some settings you must review and change to reflect your specific situation.

In my presentation at kscope 2015 I promised to release the oauth packages that will enable you to use Google, Facebook and Linked-in authentication in your own applications. I finally got around publishing them.

Please leave your remarks at github, or consider to contribute to the development.

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

Please follow directions below to complete your installation.

##install into an existing application
1. as sys: login into your database and execute the "`grant_as_sysdba.sql`" script. It will grant execute on the sys_http package to your parsing schema
2. in apex, login into your workspace
3. within the SQL Workshop:
  - upload and execute the "`apex_oauth.sql`" script which will create all database objects
  - upload and execute the "`s4a_settings_data.sql`" script which will create the settings in the s4sa_settings table
  - execute the follwing command: grant execute on `S4SG_AUTH_PCK` to `APEX_PUBLIC_USER`
4. import the plugin into your application
5. adjust the settings in the s4sa_settings table, they should reflect the settings in your developer console
  - `S4SA_GGL_API_KEY`
  - `S4SA_GGL_CLIENT_ID`
  - `S4SA_GGL_CLIENT_SECRET`
  - `S4SA_GGL_REDIRECT_URL`
6. Go to page 101 (the login-page) of your application
  - remove the username and password items
  - rename the login-button so it reflects the value of the `S4SA_GGL_LOGIN_REQUEST` record in your `S4SA_SETTINGS` table (default `GGL_LOGIN`)

##install into a new application
1. Create your application
2. follow the steps in "install into an existing application"
3. continue developing your application

#httpd configuration
It is highly advisable to use a everse proxy as described in my [blog](http://richardmartens.blogspot.nl/2015/07/making-https-webservice-requests-from.html title="blogspot").
I have included the settings as I use them in my web-server setup. This prevents you from having to create an Oracle wallet. It also alows you to use Linked-in as the oauth provider. Since Linked-in uses a specific algorithm that is not supported below Oracle 11.2.0.3.

#the S4SA_SETTINGS table
This table is the only table in use. It contains the settings for the API calls being made:

Code | Description
---- | -----------
`S4SA_GRACE_PERIOD` | This is the amount of seconds that a oauth session still has before redirecting to the login-page again
`S4SA_WALLET_PATH` | The directory the oracle wallet is in when using https requests to the oauth provider
`S4SA_WALLET_PWD` | the wallets password
`S4SA_COLLECTION_NAME` | The name of the collection in which the users' details are stored
`S4SA_GGL_LOGIN_REQUEST` | the name of the request for a google login
`S4SA_FCB_LOGIN_REQUEST` | the name of the request for a facebook login
`S4SA_LDI_LOGIN_REQUEST` | the name of the request for a linked-in login
`S4SA_API_PREFIX` | All requests are prefixed with this. use http:// to bypass the reverse proxy
`S4SA_GGL_API_KEY` | Google API key  as found in the developer console
`S4SA_GGL_CLIENT_ID` | Google client ID  as found in the developer console
`S4SA_GGL_CLIENT_SECRET` | Google Client secret as found in the developer console
`S4SA_GGL_REDIRECT_URL` | The URL Google will redirect to
`S4SA_GGL_EXTRAS` | Extra options for the google API
`S4SA_GGL_SCOPE` | Google login-scope
`S4SA_GGL_FORCE_APPROVAL` | Force approval? Y/N
`S4SA_LDI_API_KEY` | Linked-in API key as found in the developer console
`S4SA_LDI_CLIENT_ID` | Linked-in Client ID as found in the developer console
`S4SA_LDI_CLIENT_SECRET` | Linked-in Client Secret as found in the developer console
`S4SA_LDI_REDIRECT_URL` | Linked-in redirect URL
`S4SA_LDI_EXTRAS` | Extra options for the Linked-in API
`S4SA_LDI_SCOPE` | Linked-in scopes
`S4SA_LDI_FORCE_APPROVAL` | Linked-in Force approval y/n
`S4SA_FCB_CLIENT_ID` | Facebook Client ID as found in the developer console
`S4SA_FCB_CLIENT_SECRET` | Facebook Client Secret as found in the developer console
`S4SA_FCB_REDIRECT_URL` | Facebook redirection URI
`S4SA_FCB_API_VERSION` | Facebook API version used
`S4SA_FCB_EXTRAS` | Extra options for the Facebook API
`S4SA_FCB_SCOPE` | Facebook scopes
`S4SA_FCB_FORCE_APPROVAL` | Facebook force approval y/n

#license
This project is uses the [MIT license](LICENSE).
