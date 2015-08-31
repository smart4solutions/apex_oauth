create or replace package s4sg_drive_pck is
/*                           __
                         _.-~  )
              _..--~~~~,'   ,-/     _    _____ __  __          _____ _______
           .-'. . . .'   ,-','    ,' ) / ____|  \/  |   /\   |  __ \__   __|
         ,'. . . _   ,--~,-'__..-'  ,'| (___ | \  / |  /  \  | |__) | | |
       ,'. . .  (@)' ---~~~~      ,'   \___ \| |\/| | / /\ \ |  _  /  | |
      /. . . . '~~             ,-'     ____) | |  | |/ ____ \| | \ \  | |
     /. . . . .             ,-'   _  _|_____/|_|  |_/_/ _  \_\_|_ \_\ |_|
    ; . . . .  - .        ,'     | || |           | |     | | (_)
   : . . . .       _     /       | || |_ ___  ___ | |_   _| |_ _  ___  _ __  ___
  . . . . .          `-.:        |__   _/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
 . . . ./  - .          )           | | \__ \ (_) | | |_| | |_| | (_) | | | \__ \
.  . . |  _____..---.._/            |_| |___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
-~~----~~~~             ~---~~~~--~~~--~~~---~---~---~~~~----~~~~~---~~~--~~~---~~~---
--
--    NAME
--      s4sg_drive_pck
--
--    DESCRIPTION
--
--
--    MODIFIED   (DD-MM-YYYY)
--    RICHARD MARTENS   10-6-2015 11:51:44 - Created
--    RICHARD MARTENS   31-08-2015 17:59 - Added revision global
--------------------------------------------------------------------------------
*/

gc_revision constant varchar2(100) := 'Revision: 0.1 (build: 20150831221339)';

g_collname constant apex_collections.collection_name%type := 'GGL_DRIVE_STACK';

function g_collname$ return apex_collections.collection_name%type;

function set_drive_search
  ( p_folder_id   in varchar2
  , p_oauth_token in s4sa_oauth_pck.token_type
  ) return number;

function file_list
  ( p_oauth_token in s4sa_oauth_pck.token_type default null
  , p_folder_id   in varchar2                  default null
  ) return s4sg_drive_file_list pipelined;

procedure set_current_folder
  ( p_folder_id in varchar2
  , p_folder_name in varchar2);

end s4sg_drive_pck;
/

