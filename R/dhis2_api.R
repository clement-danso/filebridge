#' Authenticate with DHIS2
#' @return Authentication token
get_dhis2_token <- function() {
    req <- request(config$dhis2_url) %>%
        req_headers(
            "Content-Type" = "application/json"
        ) %>%
        req_auth_basic(config$dhis2_username, config$dhis2_password)
    
    resp <- req_perform(req)
    return(resp)
}

#' Fetch Organization Units from DHIS2
#' @return List of organization units
get_org_units <- function() {
    req <- request(paste0(config$dhis2_url, "/api/organisationUnits")) %>%
        req_auth_basic(config$dhis2_username, config$dhis2_password) %>%
        req_headers(Accept = "application/json")
    
    resp <- req_perform(req)
    data <- resp_body_json(resp)
    
    return(data$organisationUnits)
}

#' Send data to DHIS2
#' @param data Transformed data ready for DHIS2
#' @param org_unit Organization unit ID
#' @param period Period for the data
send_to_dhis2 <- function(data, org_unit, period) {
    req <- request(paste0(config$dhis2_url, "/api/dataValueSets")) %>%
        req_auth_basic(config$dhis2_username, config$dhis2_password) %>%
        req_headers("Content-Type" = "application/json") %>%
        req_body_json(list(
            dataValues = data,
            orgUnit = org_unit,
            period = period
        ))
    
    resp <- req_perform(req)
    return(resp)
} 