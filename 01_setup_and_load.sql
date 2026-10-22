-- Snowflake: database, tables, stage, load
CREATE DATABASE IF NOT EXISTS SC_DB;
CREATE SCHEMA IF NOT EXISTS SC_DB.PUBLIC;

CREATE TABLE SC_DB.PUBLIC.SUPPLIERS (
    Supplier_ID VARCHAR, Supplier_Name VARCHAR, Country VARCHAR, Region VARCHAR,
    On_Time_Delivery_Rate FLOAT, Certification_Level VARCHAR, Preferred_Supplier_Flag VARCHAR
);

CREATE TABLE SC_DB.PUBLIC.ORDERS (
    PO_ID VARCHAR, Supplier_ID VARCHAR, Raw_Material_ID VARCHAR, Order_Date DATE,
    Order_Quantity NUMBER, Unit_Cost FLOAT, Delivery_Date_Planned DATE,
    Delivery_Date_Actual DATE, Total_Cost FLOAT
);

CREATE OR REPLACE FILE FORMAT csv_ff
  TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL', 'NA', 'N/A') TRIM_SPACE = TRUE;
CREATE STAGE IF NOT EXISTS SC_DB.PUBLIC.raw_stage FILE_FORMAT = csv_ff;

-- After uploading both CSVs to the stage (use the file names shown by LIST):
-- LIST @SC_DB.PUBLIC.raw_stage;
COPY INTO SC_DB.PUBLIC.SUPPLIERS FROM @SC_DB.PUBLIC.raw_stage/supplier_master.csv FILE_FORMAT = (FORMAT_NAME = 'csv_ff');
COPY INTO SC_DB.PUBLIC.ORDERS    FROM @SC_DB.PUBLIC.raw_stage/procurement_orders.csv FILE_FORMAT = (FORMAT_NAME = 'csv_ff');
