CREATE OR REPLACE FUNCTION itemCapInvRat(INTEGER) RETURNS NUMERIC STABLE AS $$
-- Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;

BEGIN
  RETURN itemUOMRatioByType(pItemid, 'Capacity');
END;
$$ LANGUAGE 'plpgsql';
