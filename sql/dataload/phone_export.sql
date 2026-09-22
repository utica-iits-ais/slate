SELECT slate_person.banner_pidm
      ,slate_person.banner_id slate_id_matching_only
      ,device_type
      ,device_value
      ,intl_access sprtele_intl_access
      ,priority_ind
      ,notes
  FROM slate_phone
    JOIN slate_person
      ON slate_phone.banner_pidm = slate_person.banner_pidm
 WHERE slate_phone.send_ind = 'Y'