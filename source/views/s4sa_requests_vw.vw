create or replace force view s4sa_requests_vw as
select req.ID
,      req.TIJD
,      req.RESPONSE
,      req.REQUEST_SOURCE
,      req.REQUEST_URI
,      req.REQUEST_TYPE
,      req.REQUEST_HEADERS
,      req.REQUEST_BODY
from   s4sa_requests req
order by req.id desc;

