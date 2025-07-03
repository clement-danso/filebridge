# FileBridge

FileBridge is a lightweight R Shiny-based middleware application designed to bridge Ghana's national health information system (DHIMS2) and the internal DHIS2 platform for the USAID Q4H Activity. It streamlines the process of uploading, mapping, and transferring health data between these systems, ensuring data integrity and completeness for performance monitoring.

## Features
- **Secure File Upload:** Upload CSV/Excel files exported from DHIMS2.
- **Data Mapping & Transformation:** Automatically map and transform uploaded data to the DHIS2 aggregate format.
- **API Integration:** Push transformed data directly into DHIS2 via API.
- **Role-Based Authentication:** Secure access with user roles and permissions.
- **User-Friendly Interface:** Intuitive file upload and validation workflows.
- **Automated Error Checks:** Built-in data validation and feedback to ensure data quality.

## Directory Structure
```
filebridge/
├── global.R                # Global variables and shared setup
├── server.R                # Shiny server logic
├── ui.R                    # Shiny UI definition
├── R/
│   ├── auth_module.R       # Authentication and user management
│   ├── dhis2_api.R         # DHIS2 API integration functions
│   ├── excel_handler.R     # Excel/CSV file handling and validation
│   ├── utils.R             # Utility functions (data transformation, validation, etc.)
│   └── test.R              # Test scripts
└── www/
    └── custom.css          # Custom styles
```

## Getting Started

### Prerequisites
- R (>= 4.0)
- [Shiny](https://shiny.rstudio.com/)
- Required R packages: `shiny`, `dplyr`, `readxl`, `httr`, `jsonlite`, etc.

### Installation
1. Clone this repository:
   ```bash
   git clone <repo-url>
   cd filebridge
   ```
2. Install required R packages (in R console):
   ```R
   install.packages(c("shiny", "dplyr", "readxl", "httr", "jsonlite"))
   ```

### Running the App
In your R console, set the working directory to the project root and run:
```R
shiny::runApp()
```

## Usage
1. **Login:** Access the app and log in with your credentials.
2. **Upload Data:** Upload a CSV or Excel file exported from DHIMS2.
3. **Map & Validate:** Map columns as needed and validate the data.
4. **Submit:** Push the validated data to DHIS2. Receive feedback on success or errors.

## Security
- Role-based authentication restricts access to authorized users.
- Data validation and error feedback ensure only high-quality data is submitted.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)

## Contact
For questions or support, please contact the USAID Q4H Activity data team. 