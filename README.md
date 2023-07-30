# sumup-dbt
Requirements
Target customers that will use our devices efficiently and benefit the most of our product;
Know which stores, products and devices are the most efficient;
Know how long it takes for a store to adopt our devices.

Business Processes
Based on the top-level requirements above, the following processes could be identified to achieve these goals:
Identify Top 10 stores per transacted amount;
Have visibility over Top 10 products sold;
Calculate average transacted amount per store typology and country, percentage of transactions per device type and average time for  store to perform its 5 first transactions;
Detect geographical patterns (country, city);
Understand the characteristics of the stores with the highest and lowest device usage;
Implement measures to improve the performance if the stores in the lower-20 percentile;
Minimise fraudulent transactions ratio;
Target new stores based on predictions for best performer;
Observe new customer acquisition and churn rates over time and find out the reasons;
Incorporate KYC processes into onboarding least painfully for new customers;
Optimise the client pool, product assortment and device range to eliminate low-performing combinations;
List the most common struggles in the adoption process and remedy that by creating easy-to-follow guidelines and tutorials for the stores by bucket (size, geography, type) to increase adoption time;
Integrate universal reporting requirements when a new business unit, device type, store typology or geography is added;
etc.

Conceptual Data Model
To address the requirements and accommodate business processes it is suggested to structure the Data Model as following (physical structure below):
Raw data - encompasses the whole variety of data coming from a diverse set data sources to be cleaned, processed and stored in the Data Warehouse. To retain flexibility and increase performance, the raw data itself should be stored in the Data Lake for initial processing and pre-aggregation, that also could be used for staging and keeping raw data backups;
Curated Layer - contains data processed and cleaned-up using Python (including ML models) and SQL from the data sources (defined below) and is presented by device, store and transaction tables, it’s then used for calculating store / device / product / country / city specific metrics and business KPIs used in Data Science, Reporting and Analytics. The data heavy tables, for example containing transaction data, should be partitioned by transaction date (happened_at). This layer, as processing of raw data is the responsibility of a central DWH Engineering team;
Metrics Layer - is derived from curated layer (mostly in SQL) and can be also enriched with other data sources, as Google Sheets, csv, tables from other projects, following data quality conventions, however, it’s advised to incorporate most commonly used external data in curated layer, these tables include metrics on store / device / product / country / city level and can be used to calculate Data Science Models, Analytics and Business KPIs easier, as they are designed with the business processes and most common questions in mind. The data in metrics layer is also pre-joined, which cuts down the costs of querying the data. This layer should be maintained by the Data Engineers who belong to specific departments or tribes;
Business / Reporting Layer - is tailored to more specific analytics and business needs of various teams, which ensures they use a single source of truth and at the same time are able to cater to their analytics and reporting needs, also being flexible within their internal datasets. Upon demand, teams are also able to request an addition to metrics layer from engineering, should a major need arise (i.e. addition of new product family, new geography, new OKR, etc.). This layer is populated by Data Analysts and Scientists under central data guidelines and quality requirements.
The data model projects will be organised in Git repositories and optimised using DBT tools, which allows for version control, propagating changes from upstream to downstream (more on this below) and, especially at the business layer stage, develop Analytics and Data Science models using best development practices (modularity, global variables, parameters, sources, etc.). The engineering pipeline jobs could be scheduled using the workflow management platform (i.e. Airflow) for better visibility of the tasks and troubleshooting, with the most data consuming or computationally heavy tables being refreshed incrementally.
It’s important to note that in addition to data quality rules tables in the layers should follow the naming convention, especially when being used by various teams across the company, it would make projects and repos more intuitive and easy to search and query.


Data Sources
Based on the business needs and data specifications above, the following main data sources can be identified:
Internal databases - tables with data of onboarded stores, devices characteristics and typology, device error codes;
External databases - product tables from the stores, compliance tables with blacklisted merchants and cards, KYC databases;
APIs and web services - transactions data from devices, payments data from bank APIs, fraud detection microservices;
Files - geo data, lists of potential customers scraped from competitors, data from third-party providers;
etc.
The combination of internal (unique to the business), external (used by companies in the industry, i.e. blacklists), API endpoints and files, as well as a set of policies to integrate each type of data sources and strict data quality rules, allows to incorporate best practices and comply with regulations and be flexible in optimising internal approach to data storage and processing.
The data from external sources can be navigated using GUIs, for instance, performing KYC checks through dedicated portal, checking pipeline alerts in dedicated service (i.e. Datadog), observing store and allocated device performance in a shared customer portal. Other external data sources could be connected either by manually pointing our the name, location and authentication of the source, or through dedicated data connectors.

Physical Modelling
Please refer to Data Model Design file, that provides visual interpretation and relationships between the tables, it doesn’t contain full list of tables that can be added upon demand to all layers described below following the data quality rules. It gives an overview of the main tables and the data model structuring to answer the Business questions above and be able to adapt once new one arise. It’s designed to ensure long-term validity, reliability, and integrity of the data.
To normalise the data, curated layer contains entities (stores, devices, transactions) and this is further developed in metrics layer where entity specific values are calculated. This approach is used to prevent redundancy and anomalies in data maintenance. This makes querying and maintenance easier, also reducing the load on servers.
NB While the schema demonstrates the list of fields in each table, in its current version it doesn’t show the data types and field attributes and touches roughly on primary and foreign keys. Their types, formats, integrity constraints, and any other rules governing them should necessarily be defined while putting the current data model design into practice.



Data Model Maintenance
As mentioned, the proposed Data Model Design reflects a fraction of the data in the company, so one of the main challenges is to scale it while prioritising efficiency and eliminating redundancy at the same time retaining as much flexibility as possible.
The transactions from the devices located in the stores come in real time, therefore it’s crucial to decrease the downtime and be ready for troubleshooting should devices face issues. Also, the data model should be ready for heavy querying to accommodate analytics, data science, engineering and reporting needs.
The answer might lie in the implementation of GDPR-compliant (servers are located in EU) Cloud based data warehouse such as BigQuery or Snowflake. Within the company, the teams can optimise the costs based on their usage. Cloud Data Warehouse support high volume of queries and extended data volumes using parallel processing. Also, distributed computing tools, such as MapReduce, can be implemented for parallel processing and generation of data-heavy data sets and complex calculations. Another standard in the industry is Spark for large-scale data processing, that is vital for potential scaling of the data model.
Other than that, proper documentation should be in place, including data catalogue, data lineage describing the pathway of the data, data registry, reporting frameworks, data definitions and business rules to ensure clarity and accountability.
It’s extremely important to accommodate for sharing the output with other teams and ensure changes could still be made in a controlled way without potentially causing downstream model failures caused by the changes. The following steps can be implemented:
Storing Curated and Metrics layers centrally in the Data Warehouse that is owned and maintained by a dedicated DWH team, unlike Reporting / Business layers that fall under responsibility of diverse data teams;
Version control through a distributed system (i.e. GitHub), which supports distributed effort and data integrity, ensures that everyone works with the latest version of the repo  and doesn’t allow conflicting changes to be implemented at the same time;
Automated checks (i.e. Jenkins), can be implemented to run a set of tests before the changes are allowed to merge with the main branch in Git;
4-eye pull request review principle, when the change requires reviewers from Engineering and Analytics / Data Science to comply with development principles and business logic;
Usage of DBT, where the sources, variables and other SQL and Python building blocks are stored centrally to be later reused by all teams;
Real-time data alerting (i.e. Datadog) for quick detection of failures or discrepancies in the pipeline, notifications and troubleshooting;
Failure handling (i.e. backup services, limiting number of requests) in case of serious downtimes, including clear communication with internal and external stakeholders;


Data Quality
Quality is the base of everything for a data model, it needs to be ingrained into team culture, including critical thinking, searching for alternative sources for validation, fighting bias, 4/6-eye principle when making decisions and releases. Also the culture of mutual help needs to be built and multilayered verification procedures need to be in place.
As briefly described above, the Data Model is designed under data mesh principles, meaning that while data acquisition, initial processing and curated layer calculations are the responsibility of a central data team, the rest is decentralised. Each department, tribe or team has their own set of Data specialists and can perform cross-platform analytics on their own, knowing that the data is trustworthy and comes from a single source. The teams have full ownership of their data as well as flexibility to create new data sets and self-service projects. Also, distributed teams have influence on curated and metrics layers composition through formalised procedures, as they are the ones who understand the needs of business.
Data observability monitoring should be in place, (i.e. Datamin, Great Expectations) the input data for the models as well as calculated metrics should be automatically tested in real-time for consistency, completeness, relevancy. This system alerts the engineers and and data professionals responsible for the models, so the the data that doesn’t fit the expectation won’t corrupt the pipeline.
In addition to repositories that always contain the last functionable state of the data model, version control when introducing changes, clear responsibility between the Data teams on data layers maintenance and up-to-date documentation all expanded above, there can be less obvious ways to build trust in the data among stakeholders and downstream customers:
Encourage Analysts and Data Scientists to collaborate and extensively experiment in the dev environment using partitions and materialised views to reduce the computational costs;
Review the results of complex projects collectively (4 or 6-eye principle), including Engineers, Analysts and Data Scientists to validate the output;
Deploy the changes in stakeholder-facing reporting first in the dev environment (i.e. Development project in Tableau server) before rolling out the changes in the scripts, this will ensure compliance with business logic;
Documenting best practices and reporting guidelines;
Nurturing the culture critical thinking and data validation, even more so in cases where previously unfamiliar data comes.

Conclusion
The presented Data Model is a conceptual framework that can be further expanded and prepared for implementation to answer the core business questions. It’s flexible enough to anticipate other requirements that may rise around customer behaviour, device adoption and usage and can be utilised by other teams across the company with the additional capability to be expanded using the pre-aggregated layers for the main business entities (stores, devices, products). The mentioned data quality policies would ensure data integrity and support a data-driven culture and informed decision making.
