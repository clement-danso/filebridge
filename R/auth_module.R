authUI <- function(id) {
    ns <- NS(id)
    
    div(class = "login-container",
        actionButton(
            ns("login"), 
            "Login with DHIS2",
            onclick = sprintf(
                "window.location.href='%s/uaa/oauth/authorize?client_id=%s&response_type=code&redirect_uri=%s'",
                system_config$dhis2_url,
                system_config$client_id,
                URLencode(system_config$redirect_uri)
            )
        )
    )
}

authServer <- function(id) {
    moduleServer(id, function(input, output, session) {
        # Authentication state
        auth <- reactiveVal(FALSE)
        
        # Handle login attempt
        observeEvent(input$login, {
            # Show loading message
            withProgress(
                message = 'Verifying credentials...',
                value = 0.5,
                {
                    # Verify credentials against DHIS2
                    is_valid <- verify_dhis2_user(input$username, input$password)
                    
                    if (is_valid) {
                        auth(TRUE)
                    } else {
                        output$error_message <- renderText({
                            "Invalid username or password"
                        })
                    }
                }
            )
        })
        
        # Return authentication state
        return(auth)
    })
} 