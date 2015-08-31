create or replace force view s4sg_file_list_vw as
select dl.kind
,      dl.id
,      dl.etag
,      dl.selflink
,      dl.alternatelink
,      dl.embedlink
,      dl.iconlink
,      dl.thumbnaillink
,      dl.title
,      dl.mimetype
,      dl.labels
,      dl.createddate
,      dl.modifieddate
,      dl.modifiedbymedate
,      dl.lastviewedbymedate
,      dl.markedviewedbymedate
,      dl.version
,      dl.parents
,      dl.exportlinks
,      dl.userpermission
,      dl.quotabytes_used
,      dl.owners
,      dl.lastmodifyingusername
,      dl.lastmodifyinguser
,      dl.editable
,      dl.copyable
,      dl.writerscanshare
,      dl.shared
,      dl.appdatacontents
,      dl.filecontents
from   table(s4sg_drive_pck.file_list) dl;

