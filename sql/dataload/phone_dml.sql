MERGE INTO slate_phone USING (
WITH phone AS (
  SELECT t.sprtele_pidm banner_pidm
        ,t.sprtele_tele_code tele_code
        ,t.sprtele_seqno seqno
        ,CASE
           WHEN t.sprtele_tele_code = 'CELL' THEN 'mobile'
           WHEN t.sprtele_tele_code = 'MA' THEN 'phone'
           WHEN t.sprtele_tele_code = 'BU' THEN 'business'
           WHEN t.sprtele_tele_code = 'FAX' THEN 'fax'
           WHEN t.sprtele_tele_Code = 'SE' then 'seasonal'
         END AS device_type
        ,t.sprtele_phone_area || REPLACE(t.sprtele_phone_number,'-',NULL) ||
           DECODE(t.sprtele_phone_ext, NULL, NULL, ' ext. ' || t.sprtele_phone_ext) device_value
        ,t.sprtele_intl_access intl_access
        ,CASE
           WHEN t.sprtele_primary_ind = 'Y' THEN 'High Priority'
           ELSE 'Normal Priority'
         END AS priority_ind
        ,t.sprtele_comment notes
        ,ROW_NUMBER() OVER (PARTITION BY t.sprtele_pidm,t.sprtele_tele_code ORDER BY t.sprtele_status_ind NULLS FIRST, t.sprtele_seqno DESC) rowpriority
    FROM sprtele t
      JOIN ora$ptt_slate_dataload
        ON t.sprtele_pidm = ora$ptt_slate_dataload.banner_pidm
   WHERE t.sprtele_tele_code IN ('CELL','MA','BU','FAX','SE')
     AND t.sprtele_phone_number IS NOT NULL
     AND t.sprtele_status_ind IS NULL
     AND LENGTH(t.sprtele_phone_number) = 7
)
SELECT banner_pidm
      ,tele_code
      ,seqno
      ,device_type
      ,device_value
      ,intl_access
      ,priority_ind
      ,notes
  FROM phone
 WHERE phone.rowpriority = 1
) src
ON (slate_phone.banner_pidm = src.banner_pidm AND slate_phone.tele_code = src.tele_code)
WHEN MATCHED THEN
    UPDATE
       SET seqno = src.seqno
          ,device_type = src.device_type
          ,device_value = src.device_value
          ,intl_access = src.intl_access
          ,priority_ind = src.priority_ind
          ,notes = src.notes
          ,send_ind = 'Y'
          ,activity_date = SYSDATE
    WHERE ORA_HASH(slate_phone.seqno||'|'||slate_phone.device_type||'|'||slate_phone.device_value||'|'||slate_phone.intl_access||'|'||slate_phone.priority_ind||'|'||slate_phone.notes)
         <> ORA_HASH(src.seqno||'|'||src.device_type||'|'||src.device_value||'|'||src.intl_access||'|'||src.priority_ind||'|'||src.notes)
WHEN NOT MATCHED THEN
  INSERT(banner_pidm
        ,tele_code
        ,seqno
        ,device_type
        ,device_value
        ,intl_access
        ,priority_ind
        ,notes
        ,send_ind
        ,activity_date)
  VALUES(src.banner_pidm
        ,src.tele_code
        ,src.seqno
        ,src.device_type
        ,src.device_value
        ,src.intl_access
        ,src.priority_ind
        ,src.notes
        ,'Y'
        ,SYSDATE)