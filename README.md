# Supplier On-Time Delivery Analysis: Reported vs Actual Performance

Do the on-time delivery rates that suppliers report match how their purchase orders actually performed? This project answers that across **Snowflake** (loading, validation, SQL metrics), **Dataiku** (prepare and group recipes, charts) and **SAS** (correlation and paired t-test).

## Key findings
- Across **100 suppliers and 2,000 purchase orders** (orders from 2021-01-03 to 2024-04-14), suppliers report an average on-time rate of **80%**, but only **38%** of orders arrived on or before the planned date.
- Paired t-test: mean gap **0.42** (95% CI 0.38 to 0.45), t = 23.95, p < 0.0001. Every supplier's reported rate was above its actual rate.
- **No evidence that the reported rate predicts actual performance**: Pearson r = -0.05 (p = 0.60), Spearman rho = -0.05 (p = 0.65). The Snowflake correlation (-0.053) matches SAS.

![Reported vs actual](screenshots/04_reported_vs_actual_scatter.png)

## Data
Two tables (procurement orders and supplier master) from a public Kaggle supply chain dataset. The supplier names suggest the data is synthetic, so this project demonstrates a method and does not describe real suppliers. The raw CSVs are not included in this repo.

- **Supplier master (100 rows):** Supplier_ID, Supplier_Name, Country, Region, On_Time_Delivery_Rate, Certification_Level, Preferred_Supplier_Flag
- **Procurement orders (2,000 rows):** PO_ID, Supplier_ID, Raw_Material_ID, Order_Date, Order_Quantity, Unit_Cost, Delivery_Date_Planned, Delivery_Date_Actual, Total_Cost

Definition: an order is **on time** when Delivery_Date_Actual is on or before Delivery_Date_Planned.

## Workflow
1. **Snowflake** (`sql/`): created tables and a stage, loaded both CSVs, ran data quality checks, computed the overall comparison and the per-supplier correlation, and exported a supplier-level table.
2. **Dataiku**: a Prepare recipe computed `delay_days`; a Group recipe built a supplier scorecard (orders, spend, average and maximum delay, late rate, reported rate); a second Prepare recipe added a unique supplier label for the charts.
3. **SAS** (`sas/`): descriptive statistics, Pearson and Spearman correlation, a paired t-test and plots on the supplier-level table.

![Dataiku flow](screenshots/01_dataiku_flow.png)

## Data quality
| Check | Result |
|---|---|
| Distinct Supplier_ID / Supplier_Name | 100 / 96 (four names are shared by more than one supplier) |
| Distinct name + country + region | 100 |
| Duplicate PO_ID | 0 |
| Missing actual delivery date / cost | 0 / 0 |
| Total_Cost vs quantity x unit cost mismatches | 0 |
| Orders without a matching supplier | 0 |

Grouping by name alone would have merged the shared-name suppliers into one row (96 instead of 100). SQL and SAS group by supplier ID; Dataiku groups by name + country + region.

## Limitations
- On time is defined as on or before the planned date. Suppliers may use a grace period, so part of the gap could be a definition difference.
- Each supplier has about 20 orders, so each actual rate is noisy. With 100 suppliers a modest real relationship cannot be ruled out; the finding is that none was detected.
- The data appears synthetic, so findings do not describe real suppliers.
- SAS was run on a supplier-level export pasted into a DATA step, not on a live Snowflake connection.

## Repo contents
- `sql/01_setup_and_load.sql`, `02_data_quality_checks.sql`, `03_analysis_and_export.sql`
- `sas/supplier_analysis.sas`
- `screenshots/`: Dataiku flow, scorecard, charts, Snowflake check, SAS output

## Tools
Snowflake, Dataiku , SAS.
