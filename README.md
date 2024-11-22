# dbt-databricks-monitoring

A dbt package to help analyse spend in Databricks using the system generated tables.  
For more information about the system tables, please refer to the [documentation](https://docs.databricks.com/en/admin/system-tables/index.html).

# Installation

To add this to your dbt `packages.yml`, add an entry:
```yaml
  - git: https://github.com/GtheSheep/dbt-databricks-monitoring.git
    revision: v0.1.2
```

# Enabling System Schemas

Assuming you have access to the Databricks System Database, you still may not see all schemas used in this project, you can either disable these in your dbt project, or enable the schemas by following the instructions in the [docs](https://docs.databricks.com/en/admin/system-tables/index.html#enable-system-table-schemas), or using the corresponding IaC resource to do so.
