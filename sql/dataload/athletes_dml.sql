BEGIN
  DELETE FROM slate_athletes
   WHERE EXISTS
         (SELECT 1
            FROM ora$ptt_slate_dataload
           WHERE ora$ptt_slate_dataload.banner_pidm = slate_athletes.banner_pidm);

  INSERT INTO slate_athletes(banner_pidm,actc_code,slate_sport,sport_years)
  SELECT DISTINCT sp.sgrsprt_pidm banner_pidm
        ,sp.sgrsprt_actc_code actc_code
        ,CASE
           WHEN sp.sgrsprt_actc_code = 'SVBA' AND slate_person.sex = 'Male' THEN 'Men''s Baseball'
           WHEN sp.sgrsprt_actc_code = 'SVBK' AND slate_person.sex = 'Male' THEN 'Men''s Basketball'
           WHEN sp.sgrsprt_actc_code = 'SVXC' AND slate_person.sex = 'Male' THEN 'Men''s Cross Country'
           WHEN sp.sgrsprt_actc_code = 'SVFB' AND slate_person.sex = 'Male' THEN 'Men''s Football'
           WHEN sp.sgrsprt_actc_code = 'SVGF' AND slate_person.sex = 'Male' THEN 'Men''s Golf'
           WHEN sp.sgrsprt_actc_code = 'SVIC' AND slate_person.sex = 'Male' THEN 'Men''s Ice Hockey'
           WHEN sp.sgrsprt_actc_code = 'SVLX' AND slate_person.sex = 'Male' THEN 'Men''s Lacrosse'
           WHEN sp.sgrsprt_actc_code = 'SVTF' AND slate_person.sex = 'Male' THEN 'Men''s Outdoor Track'
           WHEN sp.sgrsprt_actc_code = 'SVSW' AND slate_person.sex = 'Male' THEN 'Men''s Swimming'
           WHEN sp.sgrsprt_actc_code = 'SVSO' AND slate_person.sex = 'Male' THEN 'Men''s Soccer'
           WHEN sp.sgrsprt_actc_code = 'SVTN' AND slate_person.sex = 'Male' THEN 'Men''s Tennis'
           WHEN sp.sgrsprt_actc_code = 'SVBK' AND slate_person.sex = 'Female' THEN 'Women''s Basketball'
           WHEN sp.sgrsprt_actc_code = 'SVXC' AND slate_person.sex = 'Female' THEN 'Women''s Cross Country'
           WHEN sp.sgrsprt_actc_code = 'SVFH' AND slate_person.sex = 'Female' THEN 'Women''s Field Hockey'
           WHEN sp.sgrsprt_actc_code = 'SVGF' AND slate_person.sex = 'Female' THEN 'Women''s Golf'
           WHEN sp.sgrsprt_actc_code = 'SVGY' AND slate_person.sex = 'Female' THEN 'Women''s Gymnastics'
           WHEN sp.sgrsprt_actc_code = 'SVIC' AND slate_person.sex = 'Female' THEN 'Women''s Ice Hockey'
           WHEN sp.sgrsprt_actc_code = 'SVLX' AND slate_person.sex = 'Female' THEN 'Women''s Lacrosse'
           WHEN sp.sgrsprt_actc_code = 'SVTF' AND slate_person.sex = 'Female' THEN 'Women''s Outdoor Track'
           WHEN sp.sgrsprt_actc_code = 'SVSO' AND slate_person.sex = 'Female' THEN 'Women''s Soccer'
           WHEN sp.sgrsprt_actc_code = 'SVSF' AND slate_person.sex = 'Female' THEN 'Women''s Softball'
           WHEN sp.sgrsprt_actc_code = 'SVSW' AND slate_person.sex = 'Female' THEN 'Women''s Swimming'
           WHEN sp.sgrsprt_actc_code = 'SVTN' AND slate_person.sex = 'Female' THEN 'Women''s Tennis'
           WHEN sp.sgrsprt_actc_code = 'SVVB' AND slate_person.sex = 'Female' THEN 'Women''s Volleyball'
           WHEN sp.sgrsprt_actc_code = 'SVWP' AND slate_person.sex = 'Female' THEN 'Women''s Water Polo'
         END slate_sport
        ,SUBSTR(sp.sgrsprt_term_code,1,4) sport_years
    FROM sgrsprt sp
      JOIN stvactc
        ON sp.sgrsprt_actc_code = stvactc_code
      JOIN slate_person
        ON sp.sgrsprt_pidm = slate_person.banner_pidm
      JOIN ora$ptt_slate_dataload
        ON sp.sgrsprt_pidm = ora$ptt_slate_dataload.banner_pidm
   WHERE stvactc_actp_code = 'SPRTS'
     AND stvactc_code LIKE 'SV%'
     AND sp.sgrsprt_spst_code = 'AC';
END;