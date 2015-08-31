prompt PL/SQL Developer import file
prompt Created on zondag 30 augustus 2015 by rmart
set feedback off
set define off
prompt Disabling triggers for S4SA_SETTINGS...
alter table S4SA_SETTINGS disable all triggers;
prompt Truncating S4SA_SETTINGS...
truncate table S4SA_SETTINGS;
prompt Loading S4SA_SETTINGS...
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GRACE_PERIOD', '300', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_WALLET_PATH', 'file:/u01/app/oracle/product/11.2.0/xe/wallet_new/', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_WALLET_PWD', 'secretpassword', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_COLLECTION_NAME', 'S4S_OAUTH2', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_LOGIN_REQUEST', 'GGL_LOGIN', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_LOGIN_REQUEST', 'FCB_LOGIN', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_LOGIN_REQUEST', 'LDI_LOGIN', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_API_PREFIX', 'http://revprox.local/', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_API_KEY', 'AIzaSyBF9sQ26Tk5Q__ZC5H1fSUQSg7VOfJaiJo', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_CLIENT_ID', '693589096014-95u503r437up4otncmu96dc61jlp4nib.apps.googleusercontent.com', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_CLIENT_SECRET', 'rwk7Ov4kOQg-Fl_9NvFL9IZK', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_REDIRECT_URL', 'http://dapex50.smart4apex.nl/ords/sepapex.s4sg_auth_pck.oauth2callback', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_EXTRAS', null, null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_SCOPE', 'profile email https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/drive https://mail.google.com/ https://www.google.com/m8/feeds', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_GGL_FORCE_APPROVAL', 'Y', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_API_KEY', null, null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_CLIENT_ID', '77uw6o4x8b02vz', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_CLIENT_SECRET', '0TjdvCMRqUDBLKJ2', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_REDIRECT_URL', 'http://dapex50.smart4apex.nl/ords/sepapex.s4sl_auth_pck.oauth2callback', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_EXTRAS', null, null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_SCOPE', 'r_basicprofile r_emailaddress', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_LDI_FORCE_APPROVAL', 'Y', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_CLIENT_ID', '439204406257331', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_CLIENT_SECRET', '9f077c1058dc231a70f9df44db981e38', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_REDIRECT_URL', 'http://dapex50.smart4apex.nl/ords/sepapex.s4sf_auth_pck.oauth2callback', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_API_VERSION', 'v2.3', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_EXTRAS', null, null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_SCOPE', 'public_profile user_friends email user_about_me user_photos', null);
insert into S4SA_SETTINGS (code, meaning, description)
values ('S4SA_FCB_FORCE_APPROVAL', 'Y', null);
commit;
prompt 29 records loaded
prompt Enabling triggers for S4SA_SETTINGS...
alter table S4SA_SETTINGS enable all triggers;
set feedback on
set define on
prompt Done.
