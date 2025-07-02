#' Authenticate with DHIS2
#' @return Authentication token
get_dhis2_token <- function() {
    req <- request(system_config$dhis2_url) %>%
      req_url_path_append("/api/me") %>% # Append the "/api/me" endpoint
        req_headers(
            "Content-Type" = "application/json"
        ) %>%
        req_auth_basic(system_config$api_username, system_config$api_password)

    resp <- req_perform(req)
    if (resp_status(resp) == 200) {  # HTTP 200 means success
      # Parse and return the response content
      print("Successfully authenticated!")
    } else {
      # Handle errors with a descriptive message
      stop("Authentication failed with status: ", resp_status(resp))
    }
    return(resp)
}

#' Verify DHIS2 user credentials
#' @param username DHIS2 username
#' @param password DHIS2 password
#' @param base_url DHIS2 base URL
#' @return Boolean indicating if credentials are valid
verify_dhis2_user <- function(username, password, base_url) {
    tryCatch({
        # Print debug information
        print(paste("Attempting to verify user:", username))
        print(paste("Base URL:", base_url))
        
        req <- request(base_url) %>%
            req_url_path_append("api/me") %>%
            req_auth_basic(username, password) %>%
            req_perform()
        
        # Print response status
        status <- resp_status(req)
        print(paste("Response status:", status))
        
        if (status == 200) {
            # Print successful response
            print("Authentication successful")
            return(TRUE)
        } else {
            # Print failed response
            print(paste("Authentication failed with status:", status))
            return(FALSE)
        }
    }, error = function(e) {
        # Print error details
        print(paste("Error in verification:", e$message))
        return(FALSE)
    })
}

#' Get organization units from DHIS2
#' @return List of organization units
get_org_units <- function() {
    tryCatch({
        response <- request(system_config$dhis2_url) %>%
          req_url_path_append("api/organisationUnits") %>% 
          req_auth_basic(
            system_config$api_username,
            system_config$api_password
          ) %>%
          req_perform()
        
        data <- resp_body_json(response)
        return(data$organisationUnits)
    }, error = function(e) {
        warning(paste("Error fetching organization units:", e$message))
        return(list())
    })
}

#' Send data to DHIS2
#' @param data Transformed data ready for DHIS2
#' @param org_unit Organization unit ID
#' @param period Period for the data
send_to_dhis2 <- function(data, org_unit, period) {
    req <- request(paste0(system_config$dhis2_url, "/api/dataValueSets")) %>%
        req_auth_basic(system_config$api_username, system_config$api_password) %>%
        req_headers("Content-Type" = "application/json") %>%
        req_body_json(list(
            dataValues = data,
            orgUnit = org_unit,
            period = period
        ))
    
    resp <- req_perform(req)
    return(resp)
} 
