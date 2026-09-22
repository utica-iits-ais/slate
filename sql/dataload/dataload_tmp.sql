CREATE PRIVATE TEMPORARY TABLE ora$ptt_slate_dataload ON COMMIT DROP DEFINITION AS
SELECT banner_pidm
      ,banner_id
  FROM ora$ptt_slate_dataload_constituent
GROUP BY banner_pidm,banner_id
