SELECT slate_person.banner_pidm
      ,slate_person.banner_id slate_id_matching_only
      ,address_type
      ,street
      ,street2
      ,street3
      ,city
      ,region_code
      ,postal
      ,country
      ,spraddr_activity_date
      ,from_date
      ,to_date
      ,priority_ind
  FROM slate_address
    JOIN slate_person
      ON slate_address.banner_pidm = slate_person.banner_pidm
 WHERE slate_address.send_ind = 'Y'