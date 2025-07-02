library(httr2)


  # Build the request
req <- request(system_config$dhis2_url) %>%
  req_url_path_append("/api/me") %>% # Append the "/me" endpoint
  req_headers(
    "Content-Type" = "application/json"
  ) %>%
  req_auth_basic(system_config$api_username, system_config$api_password)

#dry_run
req_dry_run(req)
return(invisible(NULL)) # Prevent further execution in dry run mode
print("well done")
  # Perform the actual request
resp <- req_perform(req)
resp
resp_body_json(resp)
resp_status(resp)

if (resp_status(resp) == 200) {  # HTTP 200 means success
  # Parse and return the response content
  content <- resp_body_json(resp)
  content
} else {
  # Handle errors with a descriptive message
  stop("Authentication failed with status: ", resp_status(resp))
}





####orgunit function testing:

response <- request(system_config$dhis2_url) %>%
  req_url_path_append("api/organisationUnits") %>% 
  req_auth_basic(
    system_config$api_username,
    system_config$api_password
  ) %>%
  req_perform()

data <- resp_body_json(response)
orgunits <- data

orgunits$organisationUnits

