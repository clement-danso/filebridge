ui <- function(request) {
    tagList(
        useShinyjs(),
        tags$head(
            tags$style(HTML("
                .login-screen { margin: 100px auto; max-width: 400px; padding: 20px; }
                .main-content { display: none; }
            "))
        ),
        
        # Login Screen
        div(id = "login-screen", class = "login-screen",
            wellPanel(
                h2("File Bridge", align = "center"),
                textInput("username", "DHIS2 Username"),
                passwordInput("password", "DHIS2 Password"),
                actionButton("login", "Login", class = "btn-primary btn-block"),
                textOutput("login_error")
            )
        ),
        
        # Main Application (hidden initially)
        div(id = "main-content", class = "main-content",
            dashboardPage(
                dashboardHeader(title = "File Bridge"),
                dashboardSidebar(
                    sidebarMenu(
                        menuItem("Upload", tabName = "upload", icon = icon("upload"))
                    )
                ),
                dashboardBody(
                    tabItems(
                        tabItem(
                            tabName = "upload",
                            fluidRow(
                                box(
                                    title = "File Upload",
                                    width = 4,
                                    fluidRow(
                                        # Start Period Row
                                        column(12,
                                            h4("Start Period"),
                                            div(style = "display: flex; gap: 10px;",
                                                div(style = "flex: 1;",
                                                    selectInput("start_year", "Year", choices = NULL)
                                                ),
                                                div(style = "flex: 1;",
                                                    selectInput("start_month", "Month", choices = NULL)
                                                )
                                            )
                                        )
                                    ),
                                    fluidRow(
                                        # End Period Row
                                        column(12,
                                            h4("End Period"),
                                            div(style = "display: flex; gap: 10px;",
                                                div(style = "flex: 1;",
                                                    selectInput("end_year", "Year", choices = NULL)
                                                ),
                                                div(style = "flex: 1;",
                                                    selectInput("end_month", "Month", choices = NULL)
                                                )
                                            )
                                        )
                                    ),
                                    hr(),
                                    # Hierarchical Location Fields in one row
                                    fluidRow(
                                        column(12,
                                            div(style = "display: flex; gap: 10px;",
                                                div(style = "flex: 1;",
                                                    selectInput("region", "Region", choices = NULL)
                                                ),
                                                div(style = "flex: 1;",
                                                    selectInput("district", "District", choices = NULL)
                                                ),
                                                div(style = "flex: 1;",
                                                    selectInput("subdistrict", "Sub-District", choices = NULL)
                                                )
                                            )
                                        )
                                    ),
                                    # Organization Unit on its own row
                                    selectInput("orgUnit", "Organization Unit", choices = NULL),
                                    downloadButton("download_template", "Download Template"),
                                    fileInput("file", "Upload Excel File",
                                            accept = c(".xlsx", ".xls"))
                                ),
                                box(
                                    title = "Data Preview",
                                    width = 8,
                                    DTOutput("preview_table")
                                )
                            )
                        )
                    )
                )
            )
        )
    )
} 