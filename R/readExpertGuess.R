#' Read ExpertGuess
#'
#' Read-in data that are based on expert guess
#'
#' @md
#' @param subtype Type of data that should be read.  One of
#'   - `Chinese_Steel_Production`: "Smooth" production estimates by Robert
#'     Pietzcker (2022).
#'   - `industry_max_secondary_steel_share`: Maximum share of secondary steel
#'     production in total steel production and years between which a linear
#'     convergence from historic to target shares is to be applied.
#'   - `cement_production_convergence_parameters`: convergence year and level
#'     (relative to global average) to which per-capita cement demand converges
#'   - `ies`
#'   - `prtp`
#'   - `CCSbounds`
#'   - `costsTradePeFinancial`
#'   - `tradeContsraints`: parameter by Nicolas Bauer (2024) for the region
#'      specific trade constraints, values different to 1 activate constraints
#'      and the value is used as effectiveness to varying degrees such as percentage numbers
#' @return magpie object of the data
#' @author Lavinia Baumstark
#' @seealso \code{\link{readSource}}
#' @examples
#' \dontrun{
#' a <- readSource(type = "ExpertGuess", subtype = "ies")
#' }
#'
#' @importFrom dplyr bind_rows filter pull select
#'
readExpertGuess <- function(subtype) {
  if (subtype == "ies") {
    a <- read.csv("ies.csv", sep = ";")
  } else if (subtype == "prtp") {
    a <- read.csv("prtp.csv", sep = ";")
  } else if (subtype == "CCSbounds") {
    a <- read.csv("CCSbounds.csv", sep = ";")
  } else if (subtype == "co2prices") {
    a <- read.csv("co2prices-2024-11.csv", sep = ";")
  } else if (subtype == "costsTradePeFinancial") {
    a <- read.csv("pm_costsTradePeFinancial_v1.1.csv",
      sep = ";",
      skip = 2
    )
  }

  if (subtype == "ies" || subtype == "prtp" || subtype == "CCSbounds" || subtype == "co2prices") {
    a$RegionCode <- NULL
    a$Country <- NULL
    out <- as.magpie(a)
  } else if (subtype == "costsTradePeFinancial") {
    out <- as.magpie(a,
      spatial = 1,
      temporal = 0,
      datacol = 3
    )
    out <- collapseNames(out)
  }

  if (subtype == "ies" || subtype == "prtp") {
    getYears(out) <- "2005"
  }

  if ("Chinese_Steel_Production" == subtype) {
    out <- readr::read_csv(
      file = "Chinese_Steel_Production.csv",
      comment = "#",
      show_col_types = FALSE
    ) %>%
      quitte::madrat_mule()
  } else if ("industry_max_secondary_steel_share" == subtype) {
    out <- readr::read_csv(
      file = "industry_max_secondary_steel_share.csv",
      comment = "#",
      show_col_types = FALSE
    ) %>%
      quitte::madrat_mule()
  } else if ("cement_production_convergence_parameters" == subtype) {
    out <- readr::read_csv(
      file = "cement_production_convergence_parameters.csv",
      col_types = "cdi",
      comment = "#"
    )

    out <- bind_rows(
      out %>%
        filter(!is.na(.data$region)),
      out %>%
        utils::head(n = 1) %>%
        filter(is.na(.data$region)) %>%
        select(-"region") %>%
        tidyr::expand_grid(region = toolGetMapping(
          name = "regionmapping_21_EU11.csv",
          type = "regional", where = "mappingfolder"
        ) %>%
          pull("RegionCode") %>%
          unique() %>%
          sort() %>%
          setdiff(out$region))
    ) %>%
      quitte::madrat_mule()
  } else if (subtype == "tradeConstraints") {
    a <- read.csv("tradeConstraints.csv", sep = ";")
    out <- as.magpie(a)
  } else if (subtype == "taxConvergenceRollback") {
    out <- read.csv("tax_convergence_rollback.csv", sep = ",",
             skip = 4, col.names = c("Year", "Region", "FE", "value"),
             header = FALSE) %>% as.magpie(datacol = 4)
  }

  return(out)
}
