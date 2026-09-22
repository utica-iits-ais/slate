SELECT slate_person.banner_pidm
      ,slate_person.banner_id slate_id_matching_only
      ,slate_athletes.slate_sport
      ,slate_athletes.sport_years
  FROM slate_athletes
    JOIN slate_person
      ON slate_athletes.banner_pidm = slate_person.banner_pidm
 WHERE slate_athletes.send_ind = 'Y'