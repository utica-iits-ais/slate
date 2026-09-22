SELECT xapp.syrxapp_erx_appidcode APPLICATION_ID
      ,i.spriden_id BANNER_ID
      ,r2.rcrapp2_pell_pgi SAI
      ,n.rnvand0_budget_amount COA
      ,n.rnvand0_gross_need GROSS_NEED
      ,nvl((SELECT 'Y'
              FROM rprawrd ra
             WHERE ra.rprawrd_aidy_code = r1.rcrapp1_aidy_code
               AND ra.rprawrd_pidm = r1.rcrapp1_pidm
               AND ra.rprawrd_fund_code = 'PIONER'
               AND ra.rprawrd_accept_amt > 0),'N') PIONEER_PASS_FINAID
  FROM spriden i
    JOIN saradap ap
      ON i.spriden_pidm = ap.saradap_pidm
    JOIN syrxapp xapp
      ON i.spriden_pidm = xapp.syrxapp_pidm
        AND ap.saradap_appl_no = xapp.syrxapp_saradap_appl_no
    JOIN stvterm tv
      ON ap.saradap_term_code_entry = tv.stvterm_code
    JOIN robinst ri
      ON  tv.stvterm_fa_proc_yr = ri.robinst_aidy_code
    JOIN rcrapp1 r1
      ON i.spriden_pidm = r1.rcrapp1_pidm
        AND tv.stvterm_fa_proc_yr = r1.rcrapp1_aidy_code
    JOIN rcrapp2 r2
      ON r1.rcrapp1_aidy_code = r2.rcrapp2_aidy_code
        AND r1.rcrapp1_pidm = r2.rcrapp2_pidm
        AND r1.rcrapp1_infc_code = r2.rcrapp2_infc_code
        AND r1.rcrapp1_seq_no = r2.rcrapp2_seq_no
    JOIN rnvand0 n
      ON n.rnvand0_aidy_code = r1.rcrapp1_aidy_code
        AND n.rnvand0_pidm = r1.rcrapp1_pidm
 WHERE r1.rcrapp1_aidy_code = :aidy
   AND r1.rcrapp1_curr_rec_ind = 'Y'
   AND xapp.syrxapp_erx_application_id like 'UU%'
   AND ap.saradap_appl_no =
       (SELECT MAX(ap2.saradap_appl_no)
          FROM saradap ap2
         WHERE ap2.saradap_pidm = ap.saradap_pidm)
        ORDER BY i.spriden_last_name,i.spriden_first_name