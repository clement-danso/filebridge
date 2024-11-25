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