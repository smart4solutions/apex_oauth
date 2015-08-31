create or replace force view s4sg_oauth_user_vw as
select c.c001            as provider
,      c.c002            as refresh_token
,      c.c003            as gotopage
,      c.c004            as provider_code
,      c.c005            as access_token
,      c.c006            as token_type
,      c.n001            as expires_in
,      c.c007            as id_token
,      c.d001            as session_start
,      c.n001 - trunc((sysdate - c.d001) * 24 * 60 * 60) as time_left
,      c.c008            as provider_error
,      c.c009            as provider_user_id
,      c.c010            as provider_user_email
,      c.c011            as provider_user_verified_email
,      c.c012            as provider_user_name
,      c.c013            as provider_user_given_name
,      c.c014            as provider_user_family_name
,      c.c015            as provider_user_link
,      c.c016            as provider_user_picture
,      c.c017            as provider_user_gender
,      c.c018            as provider_user_locale
,      c.c019            as provider_user_hd
from apex_collections c
where c.collection_name = s4sa_oauth_pck.g_collname$;

