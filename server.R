server <- function(input, output, session) {
    # Initialize reactive values
    rv <- reactiveValues(
        excel_data = NULL,
        upload_status = NULL
    )
    
    # Load organization units on startup
    observe({
        org_units <- get_org_units()
        updatePickerInput(session, "orgUnit",
                         choices = setNames(
                             map_chr(org_units, "id"),
                             map_chr(org_units, "name")
                         ))
    })
    
    # Handle file upload
    observeEvent(input$file, {
        req(input$file)
        
        withProgress(message = 'Reading Excel file', value = 0, {
            rv$excel_data <- read_excel_sheets(input$file$datapath)
            
            # Validate all sheets
            all_valid <- all(map_lgl(rv$excel_data, ~.$valid$is_valid))
            
            if (!all_valid) {
                showNotification(
                    "Some sheets contain invalid data. Please check the preview.",
                    type = "warning"
                )
            }
        })
    })
    
    # Data preview
    output$preview_table <- renderDT({
        req(rv$excel_data)
        # Show first sheet by default
        datatable(rv$excel_data[[1]]$data,
                 options = list(scrollX = TRUE))
    })
    
    # Handle data upload
    observeEvent(input$upload, {
        req(rv$excel_data, input$orgUnit, input$period)
        
        withProgress(message = 'Uploading data to DHIS2', value = 0, {
            tryCatch({
                # Process each sheet
                for (i in seq_along(rv$excel_data)) {
                    sheet_data <- rv$excel_data[[i]]
                    
                    if (sheet_data$valid$is_valid) {
                        # Transform data for DHIS2
                        transformed_data <- transform_for_dhis2(
                            sheet_data$data,
                            input$orgUnit,
                            input$period
                        )
                        
                        # Send to DHIS2
                        response <- send_to_dhis2(
                            transformed_data,
                            input$orgUnit,
                            input$period
                        )
                        
                        incProgress(1/length(rv$excel_data),
                                  detail = paste("Processed sheet", i))
                    }
                }
                
                rv$upload_status <- "Upload completed successfully"
                showNotification("Data uploaded successfully",
                               type = "success")
                
            }, error = function(e) {
                rv$upload_status <- paste("Error:", e$message)
                showNotification(paste("Upload failed:", e$message),
                               type = "error")
            })
        })
    })
    
    # Display upload status
    output$upload_status <- renderText({
        rv$upload_status
    })
} 