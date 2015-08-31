create or replace type body s4sg_drive_user is

constructor function s4sg_drive_user
  return self as result
is
begin
  return;
end s4sg_drive_user;

constructor function s4sg_drive_user
  ( p_json in json
  ) return self as result
is
begin

  kind                 := json_ext.get_string(p_json, 'kind');
  displayName          := json_ext.get_string(p_json, 'displayName');
  picture              := json_ext.get_string(p_json, 'picture.url');
  isAuthenticatedUser  := json_ext.get_string(p_json, 'isAuthenticatedUser');
  permissionId         := json_ext.get_string(p_json, 'permissionId');
  emailAddress         := json_ext.get_string(p_json, 'emailAddress');

  return;
end s4sg_drive_user;

end;
/

