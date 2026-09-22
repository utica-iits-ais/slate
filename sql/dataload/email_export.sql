SELECT slate_person.banner_pidm
      ,slate_person.banner_id slate_id_matching_only
      ,device_type
      ,NULL device_area_code
      ,device_value
      ,priority_ind
      ,goremal_comment
  FROM slate_email
    JOIN slate_person
      ON slate_email.banner_pidm = slate_person.banner_pidm
 WHERE slate_email.send_ind = 'Y'