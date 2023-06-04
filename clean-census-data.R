## Attach required packages
library(dplyr)
library(tidyr)
library(readr)

## Read in raw data from the Census Bureau
URL = paste0(
    "https://www2.census.gov/",
    "programs-surveys/popest/datasets/",
    "2020-2022/counties/totals/co-est2022-alldata.csv"
)
dat = read_csv(URL)

## Subset down to only the variables we need, remove state totals, & rename
dat = dat %>%
    filter(SUMLEV == "050") %>%
    select(STATE, COUNTY, ESTIMATESBASE2020) %>%
    rename(
        State = STATE,
        County = COUNTY,
        Pop = ESTIMATESBASE2020
    )

## Add in Connecticut county data and remove planning region data
## (see https://www.federalregister.gov/d/2022-12063)
connecticut = data.frame(
    State = "09",
    County = sprintf("%03d", seq(from = 1, to = 15, by = 2)),
    Pop = c(957419, 899498, 185186, 164245, 864835, 268555, 149788, 116418)
)
dat = dat %>%
    filter(State != "09") %>%
    bind_rows(connecticut)

## Format FIPS codes and write out results
dat = dat %>%
    mutate(fips = paste0(State, County)) %>%
    select(fips, Pop)
write_csv(x = dat, file = "county-population.csv", quote = "all")
