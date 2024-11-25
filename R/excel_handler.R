#' Read and validate Excel file
#' @param file_path Path to Excel file
#' @return List of data frames for each sheet
read_excel_sheets <- function(file_path) {
    tryCatch({
        sheets <- excel_sheets(file_path)
        
        sheet_data <- map(sheets, function(sheet) {
            df <- read_excel(file_path, sheet = sheet)
            list(
                name = sheet,
                data = df,
                valid = validate_sheet(df)
            )
        })
        
        names(sheet_data) <- sheets
        return(sheet_data)
        
    }, error = function(e) {
        stop(paste("Error reading Excel file:", e$message))
    })
}

#' Validate sheet structure and data
#' @param df Data frame to validate
#' @return List with validation results
validate_sheet <- function(df) {
    required_cols <- c("dataElement", "value")
    
    # Check required columns
    has_required_cols <- all(required_cols %in% colnames(df))
    
    # Check data types
    valid_values <- all(sapply(df$value, is.numeric))
    
    list(
        is_valid = has_required_cols && valid_values,
        errors = c(
            if(!has_required_cols) "Missing required columns",
            if(!valid_values) "Invalid numeric values"
        )
    )
} 