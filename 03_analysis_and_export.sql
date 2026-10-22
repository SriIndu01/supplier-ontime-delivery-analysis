-- On time = delivered on or before the planned date
-- Overall reported vs actual
SELECT ROUND(AVG(s.ON_TIME_DELIVERY_RATE), 3) AS avg_reported_on_time,
       ROUND(AVG(IFF(o.DELIVERY_DATE_ACTUAL <= o.DELIVERY_DATE_PLANNED, 1, 0)), 3) AS actual_on_time
FROM SC_DB.PUBLIC.ORDERS o JOIN SC_DB.PUBLIC.SUPPLIERS s ON o.SUPPLIER_ID = s.SUPPLIER_ID;

-- Does the reported rate predict actual performance? (per supplier; result: -0.053)
WITH x AS (
  SELECT s.SUPPLIER_ID, MAX(s.ON_TIME_DELIVERY_RATE) AS reported,
         AVG(IFF(o.DELIVERY_DATE_ACTUAL <= o.DELIVERY_DATE_PLANNED, 1, 0)) AS actual
  FROM SC_DB.PUBLIC.ORDERS o JOIN SC_DB.PUBLIC.SUPPLIERS s ON o.SUPPLIER_ID = s.SUPPLIER_ID
  GROUP BY s.SUPPLIER_ID)
SELECT ROUND(CORR(reported, actual), 3) AS correlation FROM x;

-- Supplier-level table exported for SAS (supplier_rates.csv)
SELECT s.SUPPLIER_ID, MAX(s.ON_TIME_DELIVERY_RATE) AS reported_rate,
       AVG(IFF(o.DELIVERY_DATE_ACTUAL <= o.DELIVERY_DATE_PLANNED, 1, 0)) AS actual_rate,
       COUNT(*) AS n_orders
FROM SC_DB.PUBLIC.ORDERS o JOIN SC_DB.PUBLIC.SUPPLIERS s ON o.SUPPLIER_ID = s.SUPPLIER_ID
WHERE o.DELIVERY_DATE_ACTUAL IS NOT NULL
GROUP BY s.SUPPLIER_ID;
