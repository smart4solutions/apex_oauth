create or replace package body json_xml as

  function escapeStr(str varchar2) return varchar2 as
    buf varchar2(32767) := '';
    ch varchar2(4);
  begin
    for i in 1 .. length(str) loop
      ch := substr(str, i, 1);
      case ch
      when '&' then buf := buf || '&amp;';
      when '<' then buf := buf || '&lt;';
      when '>' then buf := buf || '&gt;';
      when '"' then buf := buf || '&quot;';
      else buf := buf || ch;
      end case;
    end loop;
    return buf;
  end escapeStr;

/* Clob methods from printer */
  procedure add_to_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2, str varchar2) as
  begin
    if(length(str) > 32767 - length(buf_str)) then
      dbms_lob.append(buf_lob, buf_str);
      buf_str := str;
    else
      buf_str := buf_str || str;
    end if;
  end add_to_clob;

  procedure flush_clob(buf_lob in out nocopy clob, buf_str in out nocopy varchar2) as
  begin
    dbms_lob.append(buf_lob, buf_str);
  end flush_clob;

  procedure toString(obj json_value, tagname in varchar2, xmlstr in out nocopy clob, xmlbuf in out nocopy varchar2) as
    v_obj json;
    v_list json_list;

    v_keys json_list;
    v_value json_value;
    key_str varchar2(4000);
  begin
    if (obj.is_object()) then
      add_to_clob(xmlstr, xmlbuf, '<' || tagname || '>');
      v_obj := json(obj);

      v_keys := v_obj.get_keys();
      for i in 1 .. v_keys.count loop
        v_value := v_obj.get(i);
        key_str := v_keys.get(i).str;

        if(key_str = 'content') then
          if(v_value.is_array()) then
            declare
              v_l json_list := json_list(v_value);
            begin
              for j in 1 .. v_l.count loop
                if(j > 1) then add_to_clob(xmlstr, xmlbuf, chr(13)||chr(10)); end if;
                add_to_clob(xmlstr, xmlbuf, escapeStr(v_l.get(j).to_char()));
              end loop;
            end;
          else
            add_to_clob(xmlstr, xmlbuf, escapeStr(v_value.to_char()));
          end if;
        elsif(v_value.is_array()) then
          declare
            v_l json_list := json_list(v_value);
          begin
            for j in 1 .. v_l.count loop
              v_value := v_l.get(j);
              if(v_value.is_array()) then
                add_to_clob(xmlstr, xmlbuf, '<' || key_str || '>');
                add_to_clob(xmlstr, xmlbuf, escapeStr(v_value.to_char()));
                add_to_clob(xmlstr, xmlbuf, '</' || key_str || '>');
              else
                toString(v_value, key_str, xmlstr, xmlbuf);
              end if;
            end loop;
          end;
        elsif(v_value.is_null() or (v_value.is_string and v_value.get_string = '')) then
          add_to_clob(xmlstr, xmlbuf, '<' || key_str || '/>');
        else
          toString(v_value, key_str, xmlstr, xmlbuf);
        end if;
      end loop;

      add_to_clob(xmlstr, xmlbuf, '</' || tagname || '>');
    elsif (obj.is_array()) then
      v_list := json_list(obj);
      for i in 1 .. v_list.count loop
        v_value := v_list.get(i);
        toString(v_value, nvl(tagname, 'array'), xmlstr, xmlbuf);
      end loop;
    else
      add_to_clob(xmlstr, xmlbuf, '<' || tagname || '>'||escapeStr(obj.to_char())||'</' || tagname || '>');
    end if;
  end toString;

  function json_to_xml(obj json, tagname varchar2 default 'root') return xmltype as
    xmlstr clob := empty_clob();
    xmlbuf varchar2(32767) := '';
    returnValue xmltype;
  begin
    dbms_lob.createtemporary(xmlstr, true);

    toString(obj.to_json_value(), tagname, xmlstr, xmlbuf);

    flush_clob(xmlstr, xmlbuf);
    returnValue := xmltype('<?xml version="1.0"?>'||xmlstr);
    dbms_lob.freetemporary(xmlstr);
    return returnValue;
  end;

end json_xml;
/

