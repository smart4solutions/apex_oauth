create or replace type body s4sg_drive_export_link is

  -- Member procedures and functions

constructor function s4sg_drive_export_link return self as result
is
begin
  return;
end s4sg_drive_export_link;

constructor function s4sg_drive_export_link
  ( p_json in json
  ) return self as result
is
  l_json clob;
begin

  if p_json is null then
    return;
  end if;

  dbms_lob.createtemporary(l_json, true);

  p_json.to_clob(buf => l_json);

  l_json := replace(l_json, 'text/plain', 'text_plain');
  l_json := replace(l_json, 'application/pdf', 'application_pdf');
  l_json := replace(l_json, 'application/vnd', 'application_vnd');

  self.plain     := json_ext.get_string(p_json, 'text_plain');
  self.csv       := json_ext.get_string(p_json, 'csv');
  self.pdf       := json_ext.get_string(p_json, 'application_pdf');

/*
  case
    when json_ext.get_string(p_json, 'openxml') is not null then
      self.openxml   := json_ext.get_string(p_json, 'openxml');
    when json_ext.get_string(p_json, 'application_vnd.openxmlformats-officedocument.presentationml.presentation') is not null then
      self.openxml   := json_ext.get_string(p_json, 'application/vnd.openxmlformats-officedocument.presentationml.presentation');
    when json_ext.get_string(p_json, 'application_vnd.openxmlformats-officedocument.spreadsheetml.sheet') is not null then
      self.openxml   := json_ext.get_string(p_json, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    else
      self.openxml := null;
  end case;
/**/
  return;
end s4sg_drive_export_link;

end;
/

