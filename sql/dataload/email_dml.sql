MERGE INTO slate_email USING (
WITH email AS (
  SELECT e.goremal_pidm banner_pidm
        ,e.goremal_emal_code emal_code
        ,e.goremal_status_ind status_ind
        ,CASE WHEN goremal_emal_code = 'HOME' THEN 'Email'
              WHEN goremal_emal_code = 'WORK' THEN 'Business Email'
              WHEN goremal_emal_code = 'UC' THEN 'Campus Email'
              WHEN goremal_emal_code = 'URL' THEN 'Linkedin'
         END device_type
        ,e.goremal_email_address device_value
        ,CASE WHEN goremal_preferred_ind = 'Y' THEN 'High Priority'
              ELSE 'Normal Priority'
         END priority_ind
        ,e.goremal_comment
        ,ROW_NUMBER() OVER (PARTITION BY e.goremal_pidm,e.goremal_emal_code ORDER BY e.goremal_status_ind ASC, e.goremal_activity_date DESC) rowpriority
    FROM goremal e
      JOIN ora$ptt_slate_dataload
        ON e.goremal_pidm = ora$ptt_slate_dataload.banner_pidm
   WHERE (e.goremal_emal_code IN ('UC','HOME','WORK')
         OR e.goremal_emal_code = 'URL' AND LOWER(e.goremal_email_address) LIKE '%linkedin%')
     AND goremal_status_ind <> 'I'
)
SELECT banner_pidm
      ,emal_code
      ,status_ind
      ,device_type
      ,device_value
      ,priority_ind
      ,goremal_comment
  FROM email
 WHERE rowpriority = 1
) src
ON (slate_email.banner_pidm = src.banner_pidm AND slate_email.emal_code = src.emal_code)
WHEN MATCHED THEN
  UPDATE
     SET status_ind = src.status_ind
        ,device_type = src.device_type
        ,device_value = src.device_value
        ,priority_ind = src.priority_ind
        ,goremal_comment = src.goremal_comment
        ,send_ind = 'Y'
        ,activity_date = SYSDATE
  WHERE ORA_HASH(slate_email.status_ind||'|'||slate_email.device_type||'|'||slate_email.device_value||'|'||slate_email.priority_ind||'|'||slate_email.goremal_comment)
         <> ORA_HASH(src.status_ind||'|'||src.device_type||'|'||src.device_value||'|'||src.priority_ind||'|'||src.goremal_comment)
WHEN NOT MATCHED THEN
  INSERT(banner_pidm
        ,emal_code
        ,status_ind
        ,device_type
        ,device_value
        ,priority_ind
        ,goremal_comment
        ,send_ind
        ,activity_date)
  VALUES(src.banner_pidm
        ,src.emal_code
        ,src.status_ind
        ,src.device_type
        ,src.device_value
        ,src.priority_ind
        ,src.goremal_comment
        ,'Y'
        ,SYSDATE)