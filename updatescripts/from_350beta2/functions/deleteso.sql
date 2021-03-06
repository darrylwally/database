
CREATE OR REPLACE FUNCTION deleteSo(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pSoheadid    ALIAS FOR $1;
BEGIN
  RETURN deleteSo(pSoheadid, NULL);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleteSo(INTEGER, TEXT) RETURNS INTEGER AS $$
DECLARE
  pSoheadid	ALIAS FOR $1;
  pSonumber	ALIAS FOR $2;

  _r            RECORD;
  _coitemid     INTEGER;
  _result       INTEGER;

BEGIN
-- Get cohead
  SELECT * INTO _r FROM cohead WHERE (cohead_id=pSoheadid);

   IF (NOT FOUND) THEN
     RETURN 0;
   END IF;

-- Cannot delete if credit card payments
  IF (EXISTS(SELECT ccpay_id
	     FROM ccpay, payco
	     WHERE ((ccpay_status IN ('C'))
	       AND  (ccpay_id=payco_ccpay_id)
	       AND  (payco_cohead_id=pSoheadid)))) THEN
    RETURN -1;
  END IF;

-- Cannot delete if credit card history
  IF (EXISTS(SELECT ccpay_id
	     FROM ccpay, payco
	     WHERE ((ccpay_status != 'C')
	       AND  (ccpay_id=payco_ccpay_id)
	       AND  (payco_cohead_id=pSoheadid)))) THEN
    RETURN -2;
  END IF;

-- Delete Sales Order Items
  FOR _coitemid IN
  SELECT coitem_id
  FROM coitem
  WHERE (coitem_cohead_id=pSoheadid) LOOP
    SELECT deleteSoItem(_coitemid) INTO _result;
    IF (_result < 0) THEN
      RETURN _result;
    END IF;
  END LOOP;

  DELETE FROM pack
  WHERE (pack_head_id=pSoheadid and pack_head_type = 'SO');

  DELETE FROM cohead
  WHERE (cohead_id=pSoheadid);

  PERFORM deleteProject(_r.cohead_prj_id);

  DELETE FROM aropenco
  WHERE (aropenco_cohead_id=pSoheadid);

  IF (COALESCE(pSonumber,'') != '') THEN
    IF (NOT releaseSoNumber(CAST(pSonumber AS INTEGER))) THEN
      RETURN 0; -- change to -3 when releaseSoNumber returns INTEGER
    END IF;

  ELSEIF (_r.cohead_number IS NOT NULL) THEN
    IF (NOT releaseSoNumber(CAST(_r.cohead_number AS INTEGER))) THEN
      RETURN 0; -- change to -3 when releaseSoNumber returns INTEGER
    END IF;
      
  END IF;

  RETURN 0;

END;
$$ LANGUAGE 'plpgsql';

