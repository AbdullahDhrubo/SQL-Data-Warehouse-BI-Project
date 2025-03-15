# SQL Data Warehouse from Scratch - Full Hands-On Data Engineering Project

## Overview
This project demonstrates how a modern SQL Data Warehouse is designed and implemented, using industry best practices. The project reflects a deep understanding of building scalable and efficient data pipelines, integrating diverse data sources, and designing a robust data architecture. The focus is on the ETL (Extract, Transform, Load) process, data modeling, and reporting, showcasing how a data warehouse can be built to support informed decision-making.

## Key Phases of the Project

### 1. **ETL (Extract, Transform, Load) Process**
   The ETL process serves as the backbone of any data warehouse, ensuring that data is accurately extracted, transformed, and loaded to maintain the integrity and usefulness of the warehouse. The phases are applied as follows:

   - **Extract**: Raw data is extracted from multiple source systems. In this project, two sources are used:
     - **CRM System**: Provides customer relationship data that is critical for understanding customer interactions.
     - **ERP System**: Contains enterprise resource planning data that offers insights into business operations.
   
     **Full extraction** is chosen to ensure that all available data is captured, which is particularly useful for initial loads or testing when incremental updates are not yet in place.

   - **Transform**: After extraction, the raw data undergoes a series of transformations to ensure it is usable for analytics:
     - **Data Cleansing**: Duplicate records, missing values, and inconsistencies are removed to ensure the integrity of the data.
     - **Data Integration**: Data from both CRM and ERP systems is merged into a unified model to simplify access and reduce complexity.
     - **Business Logic and Rules**: Any necessary transformations based on business requirements, such as calculated fields or derived metrics, are applied to enhance the value of the data.

     These transformations ensure that the data is ready for analysis, making it more accessible and meaningful for business intelligence.

   - **Load**: After transformation, the data is loaded into the data warehouse. The data is inserted into the appropriate layers:
     - **Silver Layer**: Cleaned and integrated data, ready for analytical queries.
     - **Gold Layer**: Aggregated and summarized data, prepared for reporting and decision-making.

     **Batch processing** is employed for loading, ensuring that large datasets are ingested efficiently without overwhelming the system.

### 2. **Data Warehouse Architecture**
   The correct architecture is crucial for building a data warehouse that scales effectively and performs well. The **Medallion** architecture is chosen due to its flexibility and scalability, enabling it to handle changes in business requirements. The architecture is divided into multiple layers:

   - **Bronze Layer**: Contains raw, untransformed data from the source systems. This layer serves as the foundation for all further analysis and ensures traceability to the original data.
   - **Silver Layer**: This layer holds cleaned and transformed data that is ready for analysis but not yet aggregated.
   - **Gold Layer**: Contains the final aggregated data, optimized for reporting and analysis.

#### Medallion Architecture

| Aspect | Bronze Layer | Silver Layer | Gold Layer |
|--------|-------------|--------------|------------|
| **Definition** | Raw, unprocessed data as-is from sources | Clean & standardized data | Business-Ready data |
| **Objective** | Traceability & Debugging | (Intermediate Layer) Prepare Data for Analysis | Provide data to be consumed for reporting & Analytics |
| **Object Type** | Tables | Tables | Views |
| **Load Method** | Full Load (Truncate & Insert) | Full Load (Truncate & Insert) | None |
| **Data Transformation** | None (as-is) | - Data Cleaning<br>- Data Standardization<br>- Data Normalization<br>- Derived Columns<br>- Data Enrichment | - Data Integration<br>- Data Aggregation<br>- Business Logic & Rules |
| **Data Modeling** | None (as-is) | None (as-is) | - Star Schema<br>- Aggregated Objects<br>- Flat Tables |
| **Target Audience** | - Data Engineers | - Data Analysts<br>- Data Engineers | - Data Analysts<br>- Business Users |

   The separation into these layers ensures that the data warehouse is scalable and provides a clear distinction between raw and business-ready data.

### 3. **Data Integration**
   Integrating data from multiple systems is a fundamental part of building a data warehouse. In this project, data from the CRM and ERP systems is merged to create a unified dataset that provides a comprehensive view of the business.

   - **Merging Multiple Data Sources**: By integrating data from both the CRM and ERP systems, a single, consolidated dataset is created. This eliminates the need for analysts to access and analyze multiple systems, improving efficiency and accuracy.
   - **User-Friendly Data Model**: The integrated data model is designed to be intuitive, so business analysts can easily work with the data without complex queries or joining multiple tables.

   Data integration ensures that stakeholders have access to reliable, consolidated data, which is essential for making informed decisions.

### 4. **Error Handling and Data Quality Checks**
   Maintaining high data quality is critical to ensuring that business decisions are based on accurate information. The following error handling and quality checks are applied:

   - **Error Logging**: Error handling is incorporated into the ETL process to capture and log any issues that arise during extraction, transformation, or loading.
   - **Automated Data Quality Checks**: Before data is loaded into the warehouse, automated quality checks are run to ensure that the data meets required standards. These checks validate the completeness, consistency, and accuracy of the data.

   These measures are essential to ensure that only high-quality data reaches the reporting layers, making the data warehouse reliable and trustworthy.

### 5. **Data Modeling**
   Data modeling is key to structuring the data warehouse in a way that supports efficient querying and reporting. The **star schema** model is used in this project to design the data warehouse:

   - **Fact and Dimension Tables**: The star schema consists of fact tables that contain numeric data (e.g., sales figures) and dimension tables that provide descriptive attributes (e.g., customer or product information). This structure allows for quick aggregation and simplifies complex queries.
   - **Surrogate Keys**: Surrogate keys are used to uniquely identify records, making it easier to join tables and ensuring data consistency across the warehouse.

   The choice of the star schema model ensures that the data warehouse is optimized for reporting and analytics, with a focus on query performance and simplicity.

## Technologies Used
- **SQL Server**: The database platform used to store and manage the data warehouse.
- **ETL**: SQL scripts are used for the extraction, transformation, and loading of data.
- **Git**: Version control is used to manage and track changes in the project.
- **Notion**: Project management tool used to organize tasks and track progress.

## Detailed Implementation

### Step 1: Preparing the Environment
1. **Download the Data Files**: The dataset (CRM and ERP CSV files) must be downloaded and placed in a local directory.
2. **Install SQL Server**: SQL Server should be installed and set up to host the data warehouse.
3. **Create the Database**: SQL scripts are executed to create the required database and schema structure.

### Step 2: Data Extraction
1. **Extract Data from Source Systems**: A full extraction is performed from the CRM and ERP systems to load all available records into the Bronze layer.

### Step 3: Data Transformation
1. **Cleanse and Integrate Data**: The raw data is cleansed and integrated into a unified model that consolidates both CRM and ERP data.
2. **Apply Business Logic**: Any business rules, such as derived metrics or calculated fields, are applied to make the data more valuable for analysis.

### Step 4: Data Loading
1. **To Silver Layer**: The cleaned and integrated data is loaded into the Silver layer, making it ready for analysis.
2. **To Gold Layer**: Aggregated data is loaded into the Gold layer for reporting and decision-making.

### Step 5: Error Handling and Quality Checks
1. **Log Errors**: Error handling is implemented to capture and log any issues.
2. **Perform Data Quality Checks**: Automated checks are run to validate the data before loading it into the warehouse.

### Step 6: Data Modeling
1. **Create the Star Schema**: The fact and dimension tables are created using a star schema model to optimize query performance and simplicity.

## Contribution Guidelines
- Fork the repository, make changes, and submit pull requests.
- Open issues for any bugs or suggestions, and they will be addressed promptly.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements
- The techniques used in this project are based on real-world data engineering practices designed to provide flexibility, scalability, and efficiency.
- Thanks to the open-source community for providing the tools that make data engineering possible.




