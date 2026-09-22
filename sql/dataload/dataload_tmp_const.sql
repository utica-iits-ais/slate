CREATE PRIVATE TEMPORARY TABLE ora$ptt_slate_dataload_constituent ON COMMIT DROP DEFINITION AS
/*
SELECT i.spriden_pidm banner_pidm
      ,i.spriden_id banner_id
      ,'STUD' const_code
      ,(SELECT MIN(tv.stvterm_start_date)
          FROM sgbstdn s
            JOIN stvterm tv
              ON s.sgbstdn_term_code_eff = tv.stvterm_code
         WHERE s.sgbstdn_pidm = i.spriden_pidm
           AND s.sgbstdn_stst_code = 'AS') start_date
  FROM spriden i
    JOIN spbpers p
      ON i.spriden_pidm = p.spbpers_pidm
    JOIN sgbstdn s
      ON i.spriden_pidm = s.sgbstdn_pidm
 WHERE i.spriden_change_ind IS NULL
   AND s.sgbstdn_term_code_eff =
       (SELECT MAX(s2.sgbstdn_term_code_eff)
         FROM sgbstdn s2
         WHERE s2.sgbstdn_pidm = i.spriden_pidm)
   AND s.sgbstdn_stst_code = 'AS'
UNION
SELECT i.spriden_pidm banner_pidm
      ,i.spriden_id banner_id
      ,'FASC' const_code
      ,e.pebempl_first_hire_date start_date
  FROM spriden i
    JOIN spbpers p
      ON i.spriden_pidm = p.spbpers_pidm
    JOIN pebempl e
      ON i.spriden_pidm = e.pebempl_pidm
 WHERE i.spriden_change_ind IS NULL
   AND (SUBSTR(e.pebempl_ecls_code,1,1) IN ('P','C','F')
   AND e.pebempl_ecls_code NOT IN ('CM','CS','FV'))
   AND e.pebempl_empl_status <> 'T'
UNION

 */
SELECT i.spriden_pidm banner_pidm
     ,i.spriden_id banner_id
     ,CASE WHEN stvdegc_dlev_code = 'MA' THEN 'ALMA'
           WHEN stvdegc_dlev_code = 'DR' THEN 'ALDO'
           ELSE 'ALUM'
       END const_code
     ,dg.shrdgmr_grad_date start_date
FROM spriden i
         JOIN spbpers p
              ON i.spriden_pidm = p.spbpers_pidm
         JOIN shrdgmr dg
              ON i.spriden_pidm = dg.shrdgmr_pidm
         JOIN stvdegc
              ON dg.shrdgmr_degc_code = stvdegc_code
WHERE i.spriden_change_ind IS NULL
  AND dg.shrdgmr_degs_code = 'AW'
  AND dg.shrdgmr_term_code_grad IN
      (SELECT term_code
       FROM slate_grad_roll_ctl
       WHERE active = 'Y')