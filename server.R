server <- function(input, output, session) {
    # Authentication state
    is_authenticated <- reactiveVal(FALSE)
    
    # Handle login
    observeEvent(input$login, {
        # Print login attempt details
        print("Login attempt:")
        print(paste("Username:", input$username))
        print(paste("URL:", system_config$dhis2_url))
        
        result <- verify_dhis2_user(input$username, input$password, system_config$dhis2_url)
        print(paste("Verification result:", result))
        
        if (result) {
            is_authenticated(TRUE)
            shinyjs::hide("login-screen")
            shinyjs::show("main-content")
        } else {
            output$login_error <- renderText("Invalid username or password")
        }
    })
    
    # Load organization units after authentication
    observe({
        req(is_authenticated())
        
        org_units <- get_org_units()  # Using system credentials
        
        if (length(org_units) > 0) {
            # Extract regions (assuming level 2 units are regions)
            regions <- org_units$organisationUnits[sapply(org_units$organisationUnits, function(x) x$level == 2)]
            
            if (length(regions) > 0) {
                region_choices <- setNames(
                    sapply(regions, function(x) x$id),
                    sapply(regions, function(x) x$displayName)
                )
                
                updateSelectInput(session, "region",
                                choices = c("Select a region" = "", region_choices))
            }
        }
    })

    # Update districts based on selected region
    observeEvent(input$region, {
        req(input$region)
        org_units <- get_org_units()
        
        if (length(org_units) > 0) {
            districts <- org_units$organisationUnits[sapply(org_units$organisationUnits, function(x) 
                x$level == 3 && !is.null(x$parent) && x$parent$id == input$region)]
            
            if (length(districts) > 0) {
                district_choices <- setNames(
                    sapply(districts, function(x) x$id),
                    sapply(districts, function(x) x$displayName)
                )
                
                updateSelectInput(session, "district",
                                choices = c("Select a district" = "", district_choices))
            }
        }
    })

    # Update sub-districts based on selected district
    observeEvent(input$district, {
        req(input$district)
        org_units <- get_org_units()
        
        if (length(org_units) > 0) {
            subdistricts <- org_units$organisationUnits[sapply(org_units$organisationUnits, function(x) 
                x$level == 4 && !is.null(x$parent) && x$parent$id == input$district)]
            
            if (length(subdistricts) > 0) {
                subdistrict_choices <- setNames(
                    sapply(subdistricts, function(x) x$id),
                    sapply(subdistricts, function(x) x$displayName)
                )
                
                updateSelectInput(session, "subdistrict",
                                choices = c("Select a sub-district" = "", subdistrict_choices))
            }
        }
    })

    # Update facilities based on selected sub-district
    observeEvent(input$subdistrict, {
        req(input$subdistrict)
        org_units <- get_org_units()
        
        if (length(org_units) > 0) {
            facilities <- org_units$organisationUnits[sapply(org_units$organisationUnits, function(x) 
                x$level == 5 && !is.null(x$parent) && x$parent$id == input$subdistrict)]
            
            if (length(facilities) > 0) {
                facility_choices <- setNames(
                    sapply(facilities, function(x) x$id),
                    sapply(facilities, function(x) x$displayName)
                )
                
                updateSelectInput(session, "orgUnit",
                                choices = c("Select a facility" = "", facility_choices))
            }
        }
    })
    
    # Get current date info
    current_year <- as.numeric(format(Sys.Date(), "%Y"))
    current_month <- as.numeric(format(Sys.Date(), "%m"))
    
    # Function to get valid months for a given year
    get_valid_months <- function(year) {
        if (year < current_year) {
            # All months available for past years
            setNames(1:12, month.abb)
        } else if (year == current_year) {
            # Only up to current month for current year
            setNames(1:(current_month - 1), month.abb[1:(current_month - 1)])
        } else {
            # No months available for future years
            setNames(c(), c())
        }
    }
    
    # Update start year choices
    observe({
        updateSelectInput(session, "start_year",
                         choices = (current_year - 5):current_year,
                         selected = if (is.null(input$start_year)) current_year else input$start_year)
    })
    
    # Update end year choices
    observe({
        updateSelectInput(session, "end_year",
                         choices = (current_year - 5):current_year,
                         selected = if (is.null(input$end_year)) current_year else input$end_year)
    })
    
    # Update start month based on selected year
    observe({
        req(input$start_year)
        valid_months <- get_valid_months(as.numeric(input$start_year))
        
        updateSelectInput(session, "start_month",
                         choices = valid_months,
                         selected = if (length(valid_months) > 0) min(valid_months))
    })
    
    # Update end month based on selected year
    observe({
        req(input$end_year)
        valid_months <- get_valid_months(as.numeric(input$end_year))
        
        updateSelectInput(session, "end_month",
                         choices = valid_months,
                         selected = if (length(valid_months) > 0) max(valid_months))
    })
    
    # Validate period range
    observe({
        req(input$start_year, input$start_month, 
            input$end_year, input$end_month)
        
        start_date <- as.Date(paste(input$start_year, input$start_month, "01", sep = "-"))
        end_date <- as.Date(paste(input$end_year, input$end_month, "01", sep = "-"))
        
        if (start_date > end_date) {
            showNotification("Start period cannot be after end period", type = "error")
        }
    })
    
    # Generate sequence of periods
    periods <- reactive({
        req(input$start_year, input$start_month, 
            input$end_year, input$end_month)
        
        start_date <- as.Date(paste(input$start_year, input$start_month, "01", sep = "-"))
        end_date <- as.Date(paste(input$end_year, input$end_month, "01", sep = "-"))
        
        if (start_date > end_date) return(NULL)
        
        # Generate sequence of dates
        dates <- seq(start_date, end_date, by = "month")
        # Format as YYYYMM
        format(dates, "%Y%m")
    })
    
    # Template download handler
    output$download_template <- downloadHandler(
        filename = function() {
            "template.xlsx"
        },
        content = function(file) {
            # Validate required fields
            req(input$start_year, input$start_month,
                input$end_year, input$end_month)
            
            period_list <- periods()
            if (is.null(period_list)) {
                showNotification("Invalid period range selected", type = "error")
                return(NULL)
            }
            
            # Create template for each period
            sheet_list <- lapply(period_list, function(period) {
                year <- substr(period, 1, 4)
                month <- as.numeric(substr(period, 5, 6))
                month_name <- month.name[month]
                
                data.frame(
                    dataElement = c(
                        "# Instructions:",
                        "# 1. Replace 'example_data_element' with actual DHIS2 data element ID",
                        "# 2. Enter numeric values only in the 'value' column",
                        "# 3. Do not modify the 'period' column",
                        "example_data_element"
                    ),
                    value = c(
                        NA, NA, NA, NA,
                        123
                    ),
                    period = c(
                        NA, NA, NA, NA,
                        period
                    ),
                    stringsAsFactors = FALSE
                )
            })
            
            # Name sheets with readable names
            names(sheet_list) <- sapply(period_list, function(period) {
                year <- substr(period, 1, 4)
                month <- as.numeric(substr(period, 5, 6))
                paste(month.name[month], year)
            })
            
            writexl::write_xlsx(sheet_list, file)
        }
    )
    
    # File preview
    output$preview_table <- renderDT({
        req(input$file)
        # Add your preview logic here
    })
} 