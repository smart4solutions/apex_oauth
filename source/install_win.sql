set define off
spool apex_oauth_install_20150831221339.log
prompt ==============================
prompt = processing sequences
prompt ==============================
@@.\sequences\s4sa_req_seq.seq

prompt ==============================
prompt = processing tables
prompt ==============================
@@.\tables\s4sa_requests.tab
@@.\tables\s4sa_settings.tab

prompt ==============================
prompt = processing triggers
prompt ==============================
@@.\triggers\s4sa_req_bir_trg.trg

prompt ==============================
prompt = processing views
prompt ==============================
@@.\views\s4sa_requests_vw.vw
@@.\views\s4sg_file_list_vw.vw
@@.\views\s4sg_oauth_user_vw.vw

prompt ==============================
prompt = processing type_specs
prompt ==============================
@@.\type_specs\json.tps
@@.\type_specs\json_list.tps
@@.\type_specs\json_value.tps
@@.\type_specs\json_value_array.tps
@@.\type_specs\s4sg_drive_export_link.tps
@@.\type_specs\s4sg_drive_file.tps
@@.\type_specs\s4sg_drive_file_list.tps
@@.\type_specs\s4sg_drive_file_parent.tps
@@.\type_specs\s4sg_drive_file_parent_list.tps
@@.\type_specs\s4sg_drive_label.tps
@@.\type_specs\s4sg_drive_user.tps
@@.\type_specs\s4sg_drive_user_list.tps
@@.\type_specs\s4sg_drive_userpermission.tps

prompt ==============================
prompt = processing type_bodies
prompt ==============================
@@.\type_bodies\json.tpb
@@.\type_bodies\json_list.tpb
@@.\type_bodies\json_value.tpb
@@.\type_bodies\s4sg_drive_export_link.tpb
@@.\type_bodies\s4sg_drive_file.tpb
@@.\type_bodies\s4sg_drive_file_parent.tpb
@@.\type_bodies\s4sg_drive_label.tpb
@@.\type_bodies\s4sg_drive_user.tpb
@@.\type_bodies\s4sg_drive_userpermission.tpb

prompt ==============================
prompt = processing package_specs
prompt ==============================
@@.\package_specs\json_ac.spc
@@.\package_specs\json_dyn.spc
@@.\package_specs\json_ext.spc
@@.\package_specs\json_helper.spc
@@.\package_specs\json_ml.spc
@@.\package_specs\json_parser.spc
@@.\package_specs\json_printer.spc
@@.\package_specs\json_util_pkg.spc
@@.\package_specs\json_xml.spc
@@.\package_specs\s4sa_oauth_pck.spc
@@.\package_specs\s4sf_auth_pck.spc
@@.\package_specs\s4sg_auth_pck.spc
@@.\package_specs\s4sg_drive_pck.spc
@@.\package_specs\s4sl_auth_pck.spc

prompt ==============================
prompt = processing package_bodies
prompt ==============================
@@.\package_bodies\json_ac.bdy
@@.\package_bodies\json_dyn.bdy
@@.\package_bodies\json_ext.bdy
@@.\package_bodies\json_helper.bdy
@@.\package_bodies\json_ml.bdy
@@.\package_bodies\json_parser.bdy
@@.\package_bodies\json_printer.bdy
@@.\package_bodies\json_util_pkg.bdy
@@.\package_bodies\json_xml.bdy
@@.\package_bodies\s4sa_oauth_pck.bdy
@@.\package_bodies\s4sf_auth_pck.bdy
@@.\package_bodies\s4sg_auth_pck.bdy
@@.\package_bodies\s4sg_drive_pck.bdy
@@.\package_bodies\s4sl_auth_pck.bdy


EXEC DBMS_UTILITY.compile_schema(schema => user);
prompt Invalid objects
select o.object_name, o.object_type from user_objects o where o.status = 'INVALID' order by 1;
exit
