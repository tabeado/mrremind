#' Generate Validation Data for REMIND
#'
#' Function that generates the historical regional dataset against which the
#' REMIND model results can be compared.
#'
#' @md
#' @param rev Unused parameter here for the pleasure of [`madrat`].
#' @author David Klein, Falk Benke
#' @seealso [`fullREMIND()`], [`readSource()`], [`getCalculations()`],
#'     [`calcOutput()`]
#' @examples
#' \dontrun{
#' fullVALIDATIONREMIND()
#' }

fullVALIDATIONREMIND <- function(rev = 0) {

  years <- NULL

  # get region mappings for aggregation ----
  # Determines all regions data should be aggregated to by examining the columns
  # of the `regionmapping` and `extramappings` currently configured.

  rel <- "global" # always compute global aggregate
  for (mapping in c(getConfig("regionmapping"), getConfig("extramappings"))) {
    columns <- setdiff(
      colnames(toolGetMapping(mapping, "regional")),
      c("X", "CountryCode")
    )

    if (any(columns %in% rel)) {
      warning(
        "The following column(s) from ", mapping,
        " exist in another mapping an will be ignored: ",
        paste(columns[columns %in% rel], collapse = ", ")
      )
    }

    rel <- unique(c(rel, columns))
  }

  columnsForAggregation <- gsub(
    "RegionCode", "region",
    paste(rel, collapse = "+")
  )

  # historical data ----
  valfile <- "historical.mif"

  calcOutput("Historical",
    round = 5, file = valfile, aggregate = columnsForAggregation,
    append = FALSE, warnNA = FALSE, try = FALSE, years = years
  )

  # AGEB ----

  calcOutput(
    type = "AGEB", subtype = "balances", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "AGEB")
  )

  calcOutput(
    type = "AGEB", subtype = "electricity", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "AGEB")
  )

  # BP ----

  calcOutput(
    type = "BP", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "BP")
  )

  # CEDS Emissions ----

  # Historical emissions from CEDS data base
  calcOutput(
    "Emissions", datasource = "CEDS2024", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "CEDS")
  )

  # Historical emissions from CEDS data base, aggregated to IAMC sectors
  calcOutput(
    "Emissions", datasource = "CEDS2024_IAMC", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "CEDS IAMC sectors")
  )

  # EDGAR6 Emissions----

  # Historical emissions from EDGAR v5.0 and v6.0
  calcOutput(
    type = "Emissions", datasource = "EDGAR6", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "EDGAR6")
  )

  # EDGAR GHG Emissions----
  # does not contain as many gases as EDGAR6
  edgar <- calcOutput(
    type = "Emissions", datasource = "EDGARghg",
    aggregate = columnsForAggregation, warnNA = FALSE,
    try = FALSE, years = years
  )

  # write all regions of non-bunker variables to report
  non_bunk <- edgar[, , "International", pmatch = TRUE, invert = TRUE]
  write.report(non_bunk, file = valfile, append = TRUE,
               scenario = "historical", model = "EDGARghg")

  # write only global values of bunker variables
  bunkers <- edgar["GLO", , "International", pmatch = TRUE]
  write.report(bunkers, file = valfile, append = TRUE,
               scenario = "historical", model = "EDGARghg")

  # Ember electricity data ----

  calcOutput(
    type = "Ember", subtype = "all", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "Ember")
  )

  # Eurostat Emission Data (env_air_gge)

  calcOutput(
    type = "EurostatEmissions", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "Eurostat env_air_gge")
  )

  # European Eurostat data ----

  calcOutput(
    type = "EuropeanEnergyDatasheets",  subtype = "EU27", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "Eurostat energy_sheets")
  )

  # EU Reference Scenario ----

  calcOutput(
    type = "EU_ReferenceScenario", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # EU National GHG Projections ----

  calcOutput(
    type = "EEAGHGProjections", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # Global Energy Monitor ----

  calcOutput(
    type = "GlobalEnergyMonitor", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # HRE Heat Roadmap Europe (Final Energy) ----

  calcOutput(
    type = "HRE", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # IEA ETP ----

  calcOutput(
    type = "IEA_ETP", aggregate = columnsForAggregation, file = valfile,
    append = TRUE, warnNA = FALSE, try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # IEA Global EV Outlook ----

  calcOutput(
    type = "IEA_EVOutlook", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years, writeArgs = list(scenario = "historical")
  )


  # IEA World Energy Outlook  ----
  calcOutput(
    type = "IEA_WorldEnergyOutlook", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years, writeArgs = list(scenario = "historical")
  )

  # IEA CCUS  ----

  calcOutput(
    type = "CCScapacity", subtype = "historical", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # IRENA Capacities  ----

  calcOutput(
    type = "IRENA", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "IRENA")
  )

  # JRC IDEES ----

  calcOutput(
    type = "JRC_IDEES", subtype = "Industry", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "JRC")
  )

  calcOutput(
    type = "JRC_IDEES", subtype = "Transport", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "JRC")
  )

  calcOutput(
    type = "JRC_IDEES", subtype = "ResCom", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "JRC")
  )

  # Mueller Steel Stock ----

  calcOutput(
    type = "SteelStock", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "Mueller")
  )

  # UBA Emission data ----

  calcOutput(
    type = "UBA", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "UBA")
  )

  # UNFCCC ----

  calcOutput(
    type = "UNFCCC", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical")
  )

  # UNIDO ----

  calcOutput(
    type = "UNIDO", subtype = "INDSTAT2", file = valfile,
    aggregate = columnsForAggregation, append = TRUE, warnNA = FALSE,
    try = FALSE, years = years,
    writeArgs = list(scenario = "historical", model = "INDSTAT2")
  )
}
