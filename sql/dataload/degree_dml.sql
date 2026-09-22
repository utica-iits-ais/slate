MERGE INTO slate_degree USING (
WITH inst AS (
  SELECT stvsbgi_code sbgi_code
        ,stvsbgi_desc sbgi_desc
    FROM stvsbgi
   WHERE stvsbgi_code = '002932'
),
degs AS (
  SELECT dg.shrdgmr_pidm banner_pidm
        ,'ALUM' type
        ,dg.shrdgmr_seq_no seq_no
        ,dg.shrdgmr_term_code_grad term_code
        ,dg.shrdgmr_degc_code degc_code
        ,dg.shrdgmr_grad_date grad_date
        ,dg.shrdgmr_coll_code_1 coll_code
        ,dg.shrdgmr_camp_code camp_code
        ,dg.shrdgmr_program program_1
        ,dg.shrdgmr_majr_code_1 majr_code_1
        ,dg.shrdgmr_majr_code_2 majr_code_2
        ,dg.shrdgmr_majr_code_minr_1 minr_code_1
        ,dg.shrdgmr_majr_code_minr_2 minr_code_2
        ,dg.shrdgmr_majr_code_conc_1 conc_code_1
        ,dg.shrdgmr_majr_code_conc_2 conc_code_2
        ,dgih.shrdgih_honr_code honor_code
    FROM shrdgmr dg
      JOIN ora$ptt_slate_dataload
        ON dg.shrdgmr_pidm = ora$ptt_slate_dataload.banner_pidm
      LEFT JOIN shrdgih dgih
        ON dg.shrdgmr_pidm = dgih.shrdgih_pidm
          AND dg.shrdgmr_seq_no = dgih.shrdgih_dgmr_seq_no
   WHERE dg.shrdgmr_degs_code = 'AW'
     AND dg.shrdgmr_term_code_grad IN
         (SELECT term_code
            FROM slate_grad_roll_ctl
           WHERE active = 'Y')
)
SELECT degs.banner_pidm
      ,degs.type
      ,degs.seq_no
      ,degs.term_code
      ,inst.sbgi_code
      ,inst.sbgi_desc
      ,degs.degc_code
      ,(SELECT stvdegc_desc
          FROM stvdegc
         WHERE stvdegc_code = degs.degc_code) degc_desc
      ,degs.grad_date
      ,TO_CHAR(degs.grad_date,'YYYY') class_year
      ,degs.coll_code
      ,(SELECT stvcoll_desc
          FROM stvcoll
         WHERE stvcoll_code = degs.coll_code) coll_desc
      ,degs.camp_code
      ,(SELECT stvcamp_desc
          FROM stvcamp
         WHERE stvcamp_code = degs.camp_code) camp_desc
      ,degs.program_1
      ,degs.majr_code_1
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.majr_code_1) majr_code_1_desc
      ,degs.majr_code_2
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.majr_code_2) majr_code_2_desc
      ,degs.minr_code_1
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.minr_code_1) minr_code_1_desc
      ,degs.minr_code_2
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.minr_code_2) minr_code_2_desc
      ,degs.conc_code_1
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.conc_code_1) conc_code_1_desc
      ,degs.conc_code_2
      ,(SELECT stvmajr_desc
          FROM stvmajr
         WHERE stvmajr_code = degs.conc_code_2) conc_code_2_desc
      ,degs.honor_code
      ,(SELECT stvhonr_desc
          FROM stvhonr
         WHERE stvhonr_code = degs.honor_code) honor_desc
  FROM degs
    CROSS JOIN inst
) src
ON (slate_degree.banner_pidm = src.banner_pidm AND slate_degree.type = src.type AND NVl(slate_degree.seq_no,0) = NVL(src.seq_no,0))
WHEN MATCHED THEN
  UPDATE
     SET term_code = src.term_code
        ,sbgi_code = src.sbgi_code
        ,sbgi_desc = src.sbgi_desc
        ,degc_code = src.degc_code
        ,degc_desc = src.degc_desc
        ,grad_date = src.grad_date
        ,class_year = src.class_year
        ,coll_code = src.coll_code
        ,coll_desc = src.coll_desc
        ,camp_code = src.camp_code
        ,camp_desc = src.camp_desc
        ,program_1 = src.program_1
        ,majr_code_1 = src.majr_code_1
        ,majr_code_1_desc = src.majr_code_1_desc
        ,majr_code_2 = src.majr_code_2
        ,majr_code_2_desc = src.majr_code_2_desc
        ,minr_code_1 = src.minr_code_1
        ,minr_code_1_desc = src.minr_code_1_desc
        ,minr_code_2 = src.minr_code_2
        ,minr_code_2_desc = src.minr_code_2_desc
        ,conc_code_1 = src.conc_code_1
        ,conc_code_1_desc = src.conc_code_1_desc
        ,conc_code_2 = src.conc_code_2
        ,conc_code_2_desc = src.conc_code_2_desc
        ,honor_code = src.honor_code
        ,honor_desc = src.honor_desc
        ,activity_date = SYSDATE
        ,send_ind = 'Y'
   WHERE ORA_HASH(slate_degree.term_code||'|'||slate_degree.sbgi_code||'|'||slate_degree.sbgi_desc||'|'||slate_degree.degc_code||'|'||slate_degree.degc_desc||'|'||slate_degree.grad_date||'|'||slate_degree.coll_code||'|'||slate_degree.coll_desc||'|'||slate_degree.camp_code||'|'||slate_degree.camp_desc
                  ||'|'||slate_degree.program_1||'|'||slate_degree.majr_code_1||'|'||slate_degree.majr_code_1_desc||'|'||slate_degree.majr_code_2||'|'||slate_degree.majr_code_2_desc||'|'||slate_degree.minr_code_1||'|'||slate_degree.minr_code_1_desc||'|'||slate_degree.minr_code_2||'|'||slate_degree.minr_code_2_desc
                  ||'|'||slate_degree.conc_code_1||'|'||slate_degree.conc_code_1_desc||'|'||slate_degree.conc_code_2||'|'||slate_degree.conc_code_2_desc||'|'||slate_degree.honor_code||'|'||slate_degree.honor_desc)
         <> ORA_HASH(src.term_code||'|'||src.sbgi_code||'|'||src.sbgi_desc||'|'||src.degc_code||'|'||src.degc_desc||'|'||src.grad_date||'|'||src.coll_code||'|'||src.coll_desc||'|'||src.camp_code||'|'||src.camp_desc
                     ||'|'||src.program_1||'|'||src.majr_code_1||'|'||src.majr_code_1_desc||'|'||src.majr_code_2||'|'||src.majr_code_2_desc||'|'||src.minr_code_1||'|'||src.minr_code_1_desc||'|'||src.minr_code_2||'|'||src.minr_code_2_desc
                     ||'|'||src.conc_code_1||'|'||src.conc_code_1_desc||'|'||src.conc_code_2||'|'||src.conc_code_2_desc||'|'||src.honor_code||'|'||src.honor_desc)
WHEN NOT MATCHED THEN
  INSERT(banner_pidm
        ,type
        ,seq_no
        ,term_code
        ,sbgi_code
        ,sbgi_desc
        ,degc_code
        ,degc_desc
        ,grad_date
        ,class_year
        ,coll_code
        ,coll_desc
        ,camp_code
        ,camp_desc
        ,program_1
        ,majr_code_1
        ,majr_code_1_desc
        ,majr_code_2
        ,majr_code_2_desc
        ,minr_code_1
        ,minr_code_1_desc
        ,minr_code_2
        ,minr_code_2_desc
        ,conc_code_1
        ,conc_code_1_desc
        ,conc_code_2
        ,conc_code_2_desc
        ,honor_code
        ,honor_desc
        ,activity_date
        ,send_ind)
  VALUES(src.banner_pidm
        ,src.type
        ,src.seq_no
        ,src.term_code
        ,src.sbgi_code
        ,src.sbgi_desc
        ,src.degc_code
        ,src.degc_desc
        ,src.grad_date
        ,src.class_year
        ,src.coll_code
        ,src.coll_desc
        ,src.camp_code
        ,src.camp_desc
        ,src.program_1
        ,src.majr_code_1
        ,src.majr_code_1_desc
        ,src.majr_code_2
        ,src.majr_code_2_desc
        ,src.minr_code_1
        ,src.minr_code_1_desc
        ,src.minr_code_2
        ,src.minr_code_2_desc
        ,src.conc_code_1
        ,src.conc_code_1_desc
        ,src.conc_code_2
        ,src.conc_code_2_desc
        ,src.honor_code
        ,src.honor_desc
        ,SYSDATE
        ,'Y')