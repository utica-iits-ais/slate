SELECT banner_pidm
      ,banner_id slate_id_matching_set_override
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
  FROM slate_person
 WHERE send_ind = 'Y'
ORDER BY last_name, first_name, middle_name