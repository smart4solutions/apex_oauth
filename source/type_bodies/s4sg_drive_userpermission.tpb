create or replace type body s4sg_drive_userpermission is

constructor function s4sg_drive_userpermission return self as result
is
begin
  return;
end s4sg_drive_userpermission;

constructor function s4sg_drive_userpermission
  ( p_json in json
  ) return self as result
is
begin

  self.kind            := json_ext.get_string(p_json, 'kind');
  self.etag            := json_ext.get_string(p_json, 'etag');
  self.id              := json_ext.get_string(p_json, 'id');
  self.selfLink        := json_ext.get_string(p_json, 'selfLink');
  self.role            := json_ext.get_string(p_json, 'role');
  self.permission_type := json_ext.get_string(p_json, 'type');

  return;
end s4sg_drive_userpermission;

end;
/

