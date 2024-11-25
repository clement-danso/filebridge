ui <- dashboardPage(
    dashboardHeader(title = "File Bridge"),
    
    dashboardSidebar(
        sidebarMenu(
            menuItem("Upload", tabName = "upload", icon = icon("upload")),
            menuItem("Settings", tabName = "settings", icon = icon("cog"))
        )
    ),
    
    dashboardBody(
        useShinyjs(),
        
        tabItems(
            tabItem(
                tabName = "upload",
                fluidRow(
                    box(
                        title = "File Upload",
                        width = 4,
                        fileInput("file", "Upload Excel File",
                                accept = c(".xlsx", ".xls")),
                        selectInput("sheet_type", "Sheets Represent:",
                                  choices = c("Organization Units", "Periods")),
                        dateInput("period", "Select Period"),
                        pickerInput("orgUnit", "Organization Unit",
                                  choices = NULL, options = list(`live-search` = TRUE))
                    ),
                    box(
                        title = "Data Preview",
                        width = 8,
                        DTOutput("preview_table") %>% withSpinner()
                    )
                ),
                fluidRow(
                    box(
                        title = "Upload Status",
                        width = 12,
                        verbatimTextOutput("upload_status")
                    )
                )
            ),
            
            tabItem(
                tabName = "settings",
                fluidRow(
                    box(
                        title = "DHIS2 Configuration",
                        width = 6,
                        textInput("dhis2_url", "DHIS2 URL"),
                        textInput("dhis2_username", "Username"),
                        passwordInput("dhis2_password", "Password"),
                        actionButton("save_settings", "Save Settings",
                                   class = "btn-primary")
                    )
                )
            )
        )
    )
) 