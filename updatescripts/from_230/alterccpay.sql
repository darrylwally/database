BEGIN;
SELECT dropIfExists('TABLE', 'backup_ccpay');
CREATE TABLE backup_ccpay AS SELECT * FROM ccpay;

ALTER TABLE ccpay RENAME ccpay_yp_r_shipping	TO ccpay_r_shipping;
ALTER TABLE ccpay RENAME ccpay_yp_r_avs		TO ccpay_r_avs;
ALTER TABLE ccpay RENAME ccpay_yp_r_ordernum	TO ccpay_r_ordernum;
ALTER TABLE ccpay RENAME ccpay_yp_r_error	TO ccpay_r_error;
ALTER TABLE ccpay RENAME ccpay_yp_r_approved	TO ccpay_r_approved;
ALTER TABLE ccpay RENAME ccpay_yp_r_code	TO ccpay_r_code;
ALTER TABLE ccpay RENAME ccpay_yp_r_ref		TO ccpay_r_ref;
ALTER TABLE ccpay RENAME ccpay_yp_r_tax		TO ccpay_r_tax;
ALTER TABLE ccpay RENAME ccpay_yp_r_message	TO ccpay_r_message;
ALTER TABLE ccpay DROP ccpay_pfpro_pnref;
ALTER TABLE ccpay DROP ccpay_pfpro_result;
ALTER TABLE ccpay DROP ccpay_pfpro_cvv2match;
ALTER TABLE ccpay DROP ccpay_pfpro_respmsg;
ALTER TABLE ccpay DROP ccpay_pfpro_authcode;
ALTER TABLE ccpay DROP ccpay_pfpro_avsaddr;
ALTER TABLE ccpay DROP ccpay_pfpro_avszip;
ALTER TABLE ccpay DROP ccpay_pfpro_iavs;
COMMIT;
