#' Transform data for DHIS2 format
#' @param data Data frame to transform
#' @param org_unit Organization unit ID
#' @param period Period for the data
transform_for_dhis2 <- function(data, org_unit, period) {
    data %>%
        mutate(
            orgUnit = org_unit,
            period = period
        ) %>%
        select(dataElement, period, orgUnit, value) %>%
        as.list()
} 

#' Safely extract values from a list
#' @param list_data List to extract from
#' @param key Key to extract
#' @param default Default value if key not found
safe_extract <- function(list_data, key, default = NA_character_) {
    if (is.null(list_data[[key]])) default else list_data[[key]]
}

#' Validate organization unit data
#' @param org_unit Organization unit data
validate_org_unit <- function(org_unit) {
    !is.null(org_unit$id) && 
    !is.null(org_unit$name) && 
    !is.na(org_unit$id) && 
    !is.na(org_unit$name)
} 