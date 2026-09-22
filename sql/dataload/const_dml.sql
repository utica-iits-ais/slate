BEGIN
  MERGE INTO slate_constituent USING (
  SELECT banner_pidm
        ,const_code
        ,start_date
    FROM ora$ptt_slate_dataload_constituent
  ) src
  ON (slate_constituent.banner_pidm = src.banner_pidm AND slate_constituent.const_code = src.const_code)
  WHEN MATCHED THEN
    UPDATE
       SET start_date = src.start_date
          ,end_date = NULL
          ,activity_date = SYSDATE
          ,send_ind = 'Y'
     WHERE start_date <> src.start_date
        OR end_date IS NOT NULL
  WHEN NOT MATCHED THEN
    INSERT (banner_pidm, const_code, start_date, end_date, activity_date, send_ind)
    VALUES (src.banner_pidm, src.const_code, src.start_date, NULL, SYSDATE, 'Y');

  UPDATE slate_constituent
     SET end_date =
         NVL((SELECT MAX(stvterm_end_date) + 1
                FROM sgbstdn s
                  JOIN stvterm tv
                    ON s.sgbstdn_term_code_eff = tv.stvterm_code
               WHERE s.sgbstdn_pidm = slate_constituent.banner_pidm
                 AND s.sgbstdn_term_code_eff =
                     (SELECT MAX(s2.sgbstdn_term_code_eff)
                        FROM sgbstdn s2
                       WHERE s2.sgbstdn_pidm = slate_constituent.banner_pidm
                         AND s2.sgbstdn_stst_code = 'AS')
             ),TRUNC(SYSDATE))
        ,activity_date = SYSDATE
        ,send_ind = 'Y'
   WHERE NOT EXISTS
         (SELECT 1
            FROM ora$ptt_slate_dataload_constituent c
           WHERE c.banner_pidm = slate_constituent.banner_pidm
             AND c.const_code = 'STUD')
     AND const_code = 'STUD';

  UPDATE slate_constituent
     SET end_date =
         NVL((SELECT e.pebempl_term_date
                FROM pebempl e
               WHERE e.pebempl_pidm = slate_constituent.banner_pidm
                 AND e.pebempl_empl_status = 'T'
             ),TRUNC(SYSDATE))
        ,activity_date = SYSDATE
        ,send_ind = 'Y'
   WHERE NOT EXISTS
         (SELECT 1
            FROM ora$ptt_slate_dataload_constituent c
           WHERE c.banner_pidm = slate_constituent.banner_pidm
             AND c.const_code = 'FASC')
     AND const_code = 'FASC';
END;