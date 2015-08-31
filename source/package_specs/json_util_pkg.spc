create or replace package json_util_pkg authid current_user as

  /*

  Purpose:    JSON utilities for PL/SQL
  see http://ora-00001.blogspot.com/

  Remarks:

  Who     Date        Description
  ------  ----------  -------------------------------------
  MBR     30.01.2010  Created
  JKR     01.05.2010  Edited to fit in PL/JSON
  JKR     19.01.2011  Newest stylesheet + bugfix handling

  */

  -- generate JSON from REF Cursor
  function ref_cursor_to_json (p_ref_cursor in sys_refcursor,
                               p_max_rows in number := null,
                               p_skip_rows in number := null) return json_list;

  -- generate JSON from SQL statement
  function sql_to_json (p_sql in varchar2,
                        p_max_rows in number := null,
                        p_skip_rows in number := null) return json_list;


end json_util_pkg;
/

