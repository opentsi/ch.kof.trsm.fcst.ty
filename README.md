
# ch.kof.trsm.fcst.ty

[![dataset](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/opentsi/ch.kof.trsm.fcst.ty/main/data-raw/shield.json)](https://github.com/opentsi/ch.kof.trsm.fcst.ty/actions/workflows/update_data.yaml)

The ch.kof.trsm.fcst.ty package provides versioned time series data and
their meta information for scientific research. In addition, the package
contains the extract-transform-load (ETL) functionality that sources the
data from its original provider.

## Key Structure

Every series key has four segments, `measure.origin.region.unit`,
e.g. `l.deu.ch.lg`:

| Segment | Values |
|---------|--------|
| measure | `l` level |
| origin of guests | `all` all guests, `che` Switzerland (domestic), `for` all foreign guests, `deu` Germany, `fra` France, `ita` Italy, `usa` USA, `chn` China, `rest` other foreign markets |
| region | `ch` Switzerland (total), `alpin` Alpine region, `city` cities, `rest` rest of Switzerland |
| unit | `lg` overnight stays (Logiernächte), in thousands |

Values are overnight stays per tourism year (winter season plus summer
season) and include the KOF forecast for the coming years. KOF releases a
new forecast in May and in October/November; each release is one vintage.
The seasonal figures are in
[ch.kof.trsm.fcst.ws](https://github.com/opentsi/ch.kof.trsm.fcst.ws) and
[ch.kof.trsm.fcst.ss](https://github.com/opentsi/ch.kof.trsm.fcst.ss).

## Browse Time Series Data

You can use GitHub’s ability to render to csv to explore the datasets

## Basic Data Consumption via opentimeseries

``` r
remotes::install_github("opentsi/opentimeseries")
library(opentimeseries)

# first param `series` defaults to NULL
# fetches all series from `remote_archive`
ts <- read_open_ts(
  remote_archive = "opentsi/ch.kof.trsm.fcst.ty"
)

ts
```

Given a unique time series identifier and a GitHub repo,
*opentimeseries* will return a time series and long format `data.table`.

## Basic Usage

``` r
ts <- read_open_ts(
  remote_archive = "opentsi/ch.kof.trsm.fcst.ty"
)
```

By specifying a date in addition, you can able to obtain other versions
but the most recent one. The *opentimeseries* package will simply select
the most recent release that was available at the selected date.

Because time series data can get revised, storing vintages is important
to monitor data revisions and benchmark forecasts. Here’s a quick visual
comparison:

``` r
library(opentimeseries)
library(tsbox)

ts <- read_open_ts(series = "l.all.alpin.lg",
  remote_archive = "opentsi/ch.kof.trsm.fcst.ty"
)
ts201907 <- read_open_ts(series = "l.all.alpin.lg",
  remote_archive = "opentsi/ch.kof.trsm.fcst.ty",
  date = "2019-07-01"
)
ts201907$id <- "leading.201907"
ts$id <- sprintf("leading.202606")
ts_plot(rbind(ts201907, ts))
#> [time]: 'date'
```

![](man/figures/README-unnamed-chunk-3-1.png)<!-- -->
