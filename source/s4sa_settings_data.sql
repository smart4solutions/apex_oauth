--------------------------------------------------------
--  File created - vrijdag-november-06-2015   
--------------------------------------------------------
REM INSERTING into SEPAPEX.S4SA_SETTINGS
SET DEFINE OFF;
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GRACE_PERIOD','300','This is the amount of seconds that a oauth session still has before redirecting to the login-page again');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_WALLET_PATH','file:/u01/app/oracle/product/11.2.0/xe/wallet_new/','The directory the oracle wallet is in when using https requests to the oauth provider');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_WALLET_PWD','secretpassword','the wallets password');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_COLLECTION_NAME','S4S_OAUTH2','The name of the collection in which the users'' details are stored');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_LOGIN_REQUEST','GGL_LOGIN','the name of the request for a google login');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_LOGIN_REQUEST','FCB_LOGIN','the name of the request for a facebook login');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_LOGIN_REQUEST','LDI_LOGIN','the name of the request for a linked-in login');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_API_PREFIX','http://revprox.local/','All requests are prefixed with this. use http:// to bypass the reverse proxy');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_API_KEY','AIzaSyBF9sQ26Tk5Q__ZC5H1fSUQSg7VOfJaiJo','Google API key  as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_CLIENT_ID','693589096014-95u503r437up4otncmu96dc61jlp4nib.apps.googleusercontent.com','Google client ID  as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_CLIENT_SECRET','rwk7Ov4kOQg-Fl_9NvFL9IZK','Google Client secret as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_REDIRECT_URL','http://dapex50.smart4apex.nl/ords/sepapex.s4sg_auth_pck.oauth2callback','The URL Google will redirect to');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_EXTRAS',null,'Extra options for the google API');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_SCOPE','profile email https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/drive https://mail.google.com/ https://www.google.com/m8/feeds','Google login-scope');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_GGL_FORCE_APPROVAL','Y','Force approval? Y/N');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_API_KEY',null,'Linked-in API key as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_CLIENT_ID','77uw6o4x8b02vz','Linked-in Client ID as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_CLIENT_SECRET','0TjdvCMRqUDBLKJ2','Linked-in Client Secret as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_REDIRECT_URL','http://dapex50.smart4apex.nl/ords/sepapex.s4sl_auth_pck.oauth2callback','Linked-in redirect URL');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_EXTRAS',null,'Extra options for the Linked-in API');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_SCOPE','r_basicprofile r_emailaddress','Linked-in scopes');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_LDI_FORCE_APPROVAL','Y','Linked-in Force approval y/n');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_CLIENT_ID','439204406257331','Facebook Client ID as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_CLIENT_SECRET','9f077c1058dc231a70f9df44db981e38','Facebook Client Secret as found in the developer console');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_REDIRECT_URL','http://dapex50.smart4apex.nl/ords/sepapex.s4sf_auth_pck.oauth2callback','Facebook redirection URI');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_API_VERSION','v2.3','Facebook API version used');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_EXTRAS',null,'Extra options for the Facebook API');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_SCOPE','public_profile user_friends email user_about_me user_photos','Facebook scopes');
Insert into SEPAPEX.S4SA_SETTINGS (CODE,MEANING,DESCRIPTION) values ('S4SA_FCB_FORCE_APPROVAL','Y','Facebook force approval y/n');
