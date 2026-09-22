BEGIN
  MERGE INTO slate_person USING (
  SELECT i.spriden_pidm banner_pidm
        ,i.spriden_id banner_id
        ,p.spbpers_name_prefix prefix
        ,i.spriden_first_name first_name
        ,i.spriden_mi middle_name
        ,i.spriden_last_name last_name
        ,p.spbpers_name_suffix suffix
        ,(SELECT  LISTAGG(DISTINCT gorrace_desc,', ') WITHIN GROUP (ORDER BY gorrace_desc)
            FROM gorprac
              JOIN gorrace
                ON gorrace_race_cde = gorprac_race_cde
           WHERE gorprac_pidm = i.spriden_pidm) all_races
        ,COALESCE(p.spbpers_pref_first_name,spriden_first_name) preferred_name
        ,(SELECT LISTAGG(DISTINCT i2.spriden_last_name,', ') WITHIN GROUP (ORDER BY i2.spriden_last_name)
            FROM spriden i2
           WHERE i2.spriden_pidm = i.spriden_pidm
             AND i2.spriden_change_ind IS NOT NULL
             AND UPPER(i2.spriden_last_name) != UPPER(i.spriden_last_name)
             AND UPPER(i2.spriden_last_name) != UPPER(i.spriden_mi)) alternate_last_name
        ,DECODE(p.spbpers_sex,'M','Male','F','Female') sex
        ,p.spbpers_birth_date birthdate
        ,DECODE(p.spbpers_citz_code,'Y','United States') citizenship1_from_citz
        ,DECODE(p.spbpers_mrtl_code,'N','S','U',NULL,p.spbpers_mrtl_code) marital_status
        ,DECODE(p.spbpers_dead_ind,'Y',1,'N',0,p.spbpers_dead_ind) deceased_ind
        ,p.spbpers_dead_date deceased_date
        ,DECODE(p.spbpers_ethn_cde,'2',1,0) hispanic
    FROM ora$ptt_slate_dataload
      JOIN spriden i
        ON ora$ptt_slate_dataload.banner_pidm = i.spriden_pidm
      JOIN spbpers p
        ON ora$ptt_slate_dataload.banner_pidm = p.spbpers_pidm
   WHERE i.spriden_change_ind IS NULL
  ) src
  ON (slate_person.banner_pidm = src.banner_pidm)
  WHEN MATCHED THEN
    UPDATE
       SET banner_id = src.banner_id
          ,prefix = src.prefix
          ,first_name = src.first_name
          ,middle_name = src.middle_name
          ,last_name = src.last_name
          ,suffix = src.suffix
          ,all_races = src.all_races
          ,preferred_name = src.preferred_name
          ,alternate_last_name = src.alternate_last_name
          ,sex = src.sex
          ,birthdate = src.birthdate
          ,citizenship1_from_citz = src.citizenship1_from_citz
          ,marital_status = src.marital_status
          ,deceased_ind = src.deceased_ind
          ,deceased_date = src.deceased_date
          ,hispanic = src.hispanic
          ,activity_date = sysdate
          ,send_ind = 'Y'
     WHERE ORA_HASH(slate_person.banner_id||'|'||slate_person.prefix||'|'||
                    slate_person.first_name||'|'||slate_person.middle_name||'|'||slate_person.last_name||'|'||
                    slate_person.suffix||'|'||slate_person.all_races||'|'||slate_person.preferred_name||'|'||slate_person.alternate_last_name||'|'||
                    slate_person.sex||'|'||slate_person.birthdate||'|'||slate_person.citizenship1_from_citz||'|'||slate_person.marital_status||'|'||
                    slate_person.deceased_ind||'|'||slate_person.deceased_date||'|'||slate_person.hispanic
                   )
           <> ORA_HASH(src.banner_id||'|'||src.prefix||'|'||
                       src.first_name||'|'||src.middle_name||'|'||src.last_name||'|'||
                       src.suffix||'|'||src.all_races||'|'||src.preferred_name||'|'||src.alternate_last_name||'|'||
                       src.sex||'|'||src.birthdate||'|'||src.citizenship1_from_citz||'|'||src.marital_status||'|'||
                       src.deceased_ind||'|'||src.deceased_date||'|'||src.hispanic
                      )
  WHEN NOT MATCHED THEN
    INSERT(banner_pidm
          ,banner_id
          ,prefix
          ,first_name
          ,middle_name
          ,last_name
          ,suffix
          ,all_races
          ,preferred_name
          ,alternate_last_name
          ,sex
          ,birthdate
          ,citizenship1_from_citz
          ,marital_status
          ,deceased_ind
          ,deceased_date
          ,hispanic
          ,activity_date
          ,send_ind)
    VALUES(src.banner_pidm
          ,src.banner_id
          ,src.prefix
          ,src.first_name
          ,src.middle_name
          ,src.last_name
          ,src.suffix
          ,src.all_races
          ,src.preferred_name
          ,src.alternate_last_name
          ,src.sex
          ,src.birthdate
          ,src.citizenship1_from_citz
          ,src.marital_status
          ,src.deceased_ind
          ,src.deceased_date
          ,src.hispanic
          ,sysdate
          ,'Y');
END;