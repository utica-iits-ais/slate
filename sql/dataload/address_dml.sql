MERGE INTO slate_address USING (
WITH address AS (
SELECT addr.spraddr_pidm banner_pidm
      ,addr.spraddr_atyp_code address_type_code
      ,CASE
         WHEN addr.spraddr_atyp_code IN ('MA') THEN 'mailing'
         WHEN addr.spraddr_atyp_code IN ('BU') THEN 'business'
         WHEN addr.spraddr_atyp_code in ('UC') THEN 'campus'
         WHEN addr.spraddr_atyp_code in ('SE') THEN 'seasonal'
       END AS address_type
      ,addr.spraddr_seqno seqno
      ,addr.spraddr_street_line1 street
      ,addr.spraddr_street_line2 street2
      ,addr.spraddr_street_line3 street3
      ,addr.spraddr_city city
      ,addr.spraddr_stat_code region_code
      ,addr.spraddr_zip postal
      ,NVL(natn.stvnatn_nation,'USA') country
      ,addr.spraddr_activity_date
      ,addr.spraddr_from_date from_date
      ,addr.spraddr_to_date to_date
      ,CASE
         WHEN addr.spraddr_status_ind = 'I' THEN 'Inactive'
       END priority_ind
      ,ROW_NUMBER() OVER (PARTITION BY addr.spraddr_pidm,addr.spraddr_atyp_code ORDER BY addr.spraddr_status_ind NULLS FIRST, addr.spraddr_to_date DESC NULLS FIRST, addr.spraddr_seqno DESC) rown
  FROM spraddr addr
    LEFT JOIN stvnatn natn
      ON addr.spraddr_natn_code = natn.stvnatn_code
    JOIN ora$ptt_slate_dataload
      ON addr.spraddr_pidm = ora$ptt_slate_dataload.banner_pidm
  WHERE addr.spraddr_atyp_code IN ('MA','BU')
)
SELECT banner_pidm
      ,address_type_code
      ,address_type
      ,seqno
      ,street
      ,street2
      ,street3
      ,city
      ,region_code
      ,postal
      ,country
      ,spraddr_activity_date
      ,from_date
      ,to_date
      ,priority_ind
  FROM address
 WHERE address.rown = 1
) src
ON (slate_address.banner_pidm = src.banner_pidm AND slate_address.address_type_code = src.address_type_code)
WHEN MATCHED THEN
  UPDATE
     SET address_type = src.address_type
        ,seqno = src.seqno
        ,street = src.street
        ,street2 = src.street2
        ,street3 = src.street3
        ,city = src.city
        ,region_code = src.region_code
        ,postal = src.postal
        ,country = src.country
        ,spraddr_activity_date = src.spraddr_activity_date
        ,from_date = src.from_date
        ,to_date = src.to_date
        ,priority_ind = src.priority_ind
        ,send_ind = 'Y'
        ,activity_date = SYSDATE
   WHERE ORA_HASH(slate_address.address_type||'|'||slate_address.seqno||'|'||
                  slate_address.street||'|'||slate_address.street2||'|'||slate_address.street3||'|'||
                  slate_address.city||'|'||slate_address.region_code||'|'||slate_address.postal||'|'||slate_address.country||'|'||
                  slate_address.spraddr_activity_date||'|'||slate_address.from_date||'|'||slate_address.to_date||'|'||slate_address.priority_ind
                 )
           <> ORA_HASH(src.address_type||'|'||src.seqno||'|'||
                       src.street||'|'||src.street2||'|'||src.street3||'|'||
                       src.city||'|'||src.region_code||'|'||src.postal||'|'||src.country||'|'||
                       src.spraddr_activity_date||'|'||src.from_date||'|'||src.to_date||'|'||src.priority_ind
                      )
WHEN NOT MATCHED THEN
  INSERT(banner_pidm
        ,address_type_code
        ,address_type
        ,seqno
        ,street
        ,street2
        ,street3
        ,city
        ,region_code
        ,postal
        ,country
        ,spraddr_activity_date
        ,from_date
        ,to_date
        ,priority_ind
        ,send_ind
        ,activity_date)
  VALUES(src.banner_pidm
        ,src.address_type_code
        ,src.address_type
        ,src.seqno
        ,src.street
        ,src.street2
        ,src.street3
        ,src.city
        ,src.region_code
        ,src.postal
        ,src.country
        ,src.spraddr_activity_date
        ,src.from_date
        ,src.to_date
        ,src.priority_ind
        ,'Y'
        ,SYSDATE)