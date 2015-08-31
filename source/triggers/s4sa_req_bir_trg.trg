create or replace trigger s4sa_REQ_BIR_TRG
  before insert
  on s4sa_requests
  for each row
declare
  -- local variables here
begin
  :new.id := s4sa_req_seq.nextval;
end s4sa_REQ_BIR_TRG;
/

