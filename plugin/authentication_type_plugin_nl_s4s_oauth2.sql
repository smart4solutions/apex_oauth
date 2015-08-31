set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.0.00.31'
,p_default_workspace_id=>1679746812697720
,p_default_application_id=>102
,p_default_owner=>'SEPAPEX'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/authentication_type/nl_s4s_oauth2
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(70500439850911113)
,p_plugin_type=>'AUTHENTICATION TYPE'
,p_name=>'NL.S4S.OAUTH2'
,p_display_name=>'S4S oAuth 2'
,p_category=>'MISC'
,p_supported_ui_types=>'DESKTOP'
,p_session_sentry_function=>'#OWNER#.s4sa_oauth_pck.auth_sentry'
,p_authentication_function=>'#OWNER#.s4sa_oauth_pck.authenticate'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
