SELECT slate_person.banner_pidm
      ,slate_person.banner_id slate_id_matching_only
      ,slate_constituent.const_code constituent_code
      ,atvdonr_desc constituent_value
      ,slate_constituent.start_date
      ,slate_constituent.end_date
  FROM slate_constituent
    JOIN slate_person
      ON slate_constituent.banner_pidm = slate_person.banner_pidm
    JOIN atvdonr
      ON slate_constituent.const_code = atvdonr_code
 WHERE slate_constituent.send_ind = 'Y'  