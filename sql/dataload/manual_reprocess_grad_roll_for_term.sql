-- select * from slate_grad_roll_ctl for update

--select *
--  from slate_degree
update slate_degree
   set slate_degree.send_ind = 'Y'
 where slate_degree.term_code = '202610'
   and slate_degree.send_ind = 'N';

--select *
--  from slate_person
update slate_person
   set slate_person.send_ind = 'Y'
 where slate_person.banner_pidm in
       (select banner_pidm
          from slate_degree
         where slate_degree.term_code = '202610');

--select *
--  from slate_constituent
update slate_constituent
   set slate_constituent.send_ind = 'Y'
 where slate_constituent.banner_pidm in         
       (select banner_pidm
          from slate_degree
         where slate_degree.term_code = '202610');


--select *
--  from slate_address
update slate_address
   set slate_address.send_ind = 'Y'
 where slate_address.banner_pidm in 
       (select banner_pidm
          from slate_degree
         where slate_degree.term_code = '202610');
         
--select *
--  from slate_phone
update slate_phone
   set slate_phone.send_ind = 'Y'
 where slate_phone.banner_pidm in 
       (select banner_pidm
          from slate_degree
         where slate_degree.term_code = '202610');

--select *
--  from slate_email
update slate_email
   set slate_email.send_ind = 'Y'
 where slate_email.banner_pidm in
       (select banner_pidm
          from slate_degree
         where slate_degree.term_code = '202610');                   
         
         
/*
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
*/       
