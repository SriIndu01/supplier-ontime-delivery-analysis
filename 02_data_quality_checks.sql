-- Supplier identifiers: 100 rows, 100 distinct IDs, 96 distinct names
SELECT COUNT(*) AS supplier_rows, COUNT(DISTINCT SUPPLIER_ID) AS distinct_ids,
       COUNT(DISTINCT SUPPLIER_NAME) AS distinct_names
FROM SC_DB.PUBLIC.SUPPLIERS;

-- Which names are shared
SELECT SUPPLIER_NAME, COUNT(*) AS n, LISTAGG(SUPPLIER_ID, ', ') AS ids,
       LISTAGG(COUNTRY || ' / ' || REGION, ' ; ') AS locations
FROM SC_DB.PUBLIC.SUPPLIERS GROUP BY SUPPLIER_NAME HAVING COUNT(*) > 1;

-- Name + country + region is unique per supplier (returns 100)
SELECT COUNT(DISTINCT SUPPLIER_NAME || '|' || COUNTRY || '|' || REGION) AS distinct_combos
FROM SC_DB.PUBLIC.SUPPLIERS;

-- Orders: 2,000 rows, 0 duplicates, 0 missing dates/costs, 0 cost mismatches
SELECT COUNT(*) AS total_orders, COUNT(DISTINCT PO_ID) AS distinct_po_ids,
       MIN(ORDER_DATE) AS first_order, MAX(ORDER_DATE) AS last_order,
       COUNT_IF(DELIVERY_DATE_ACTUAL IS NULL) AS missing_actual_date,
       COUNT_IF(TOTAL_COST IS NULL) AS missing_cost,
       COUNT_IF(ABS(TOTAL_COST - ORDER_QUANTITY * UNIT_COST) > 0.01) AS cost_mismatch
FROM SC_DB.PUBLIC.ORDERS;

-- Orders without a matching supplier (returns 0)
SELECT COUNT(*) AS orphan_orders
FROM SC_DB.PUBLIC.ORDERS o LEFT JOIN SC_DB.PUBLIC.SUPPLIERS s ON o.SUPPLIER_ID = s.SUPPLIER_ID
WHERE s.SUPPLIER_ID IS NULL;
