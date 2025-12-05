library(cowplot)
library(ggplot2)

all_mean <- .5
all_sd <- .25
per1 <- .25
per2 <- .75

dd <- function(x) {
  dnorm(x, mean = all_mean, sd = all_sd)
}
z1 <- abs(per1 - all_mean)/all_sd
z2 <- abs(per2 - all_mean)/all_sd
pc1 <- round(100*(pnorm(z1)), digits=0)
pc2 <- round(100*(pnorm(z2)), digits=0)
t1 <- paste0(as.character(pc1), "th percentile")
t2 <- paste0(as.character(pc2), "th percentile")
p33 <- all_mean + (qnorm(.3333) * all_sd)
p67 <- all_mean + (qnorm(.6667) * all_sd)
ggplot(data.frame(x=c(-.5,1.5)), aes(x=x)) +
  stat_function(fun = dd) +
  geom_vline(aes(xintercept = per1), colour = "salmon", linetype = "dotted") +
  geom_vline(aes(xintercept = per2), colour = "salmon", linetype = "dotted") +
  geom_label(aes(x=per1, y = .1, label = "25% percentile")) +
  geom_label(aes(x=per2, y = .1, label = "75% percentile")) +
  geom_segment(aes(x=-.5, y = 1.75, xend = p33, yend = 1.75), colour = "brown") +
  geom_segment(aes(x=p33, y = 1.75, xend = p67,yend = 1.75), colour = "darkgoldenrod") +
  geom_segment(aes(x=p67, y = 1.75, xend = 1.5, yend = 1.75), colour = "cyan4") +
  geom_text(aes(-.5 - (-.5-p33)/2, y = 1.8, label = "Low"), colour = "brown") +
  geom_text(aes(all_mean, y = 1.8, label = "Moderate"), colour = "darkgoldenrod") +
  geom_text(aes(1.5-(1.5-p67)/2, y = 1.8, label = "High"), colour = "cyan4") +
  labs(x = "Percentile", y = "Viral load (arbitrary unit)") +
  guides(x = "none", y = "none")



p1 <- ggplot(data = data.frame(x = c(-.5,1.5)), aes(x)) + 
  stat_function(fun = dnorm, n = 101, args = list(mean = .5, sd = .25)) + ylab("") + 
  geom_hline(aes(yintercept = 0)) +
  geom_segment(aes(x = .25, y = 0, xend = .25, yend = y), linetype = "dotted") +
  geom_vline(aes(xintercept = .75)) +
  scale_y_continuous(breaks = NULL)
p1

library(tidyverse)
devtools::install_github("covid-19-Re/estimateR")
library(estimateR)

estimateR_seed <- 0

## SARS-CoV-2 Delay between onset of symptoms and shedding into wastewater in days
# Ref: Benefield et al., medRxiv, 2020
sars_cov_2_distribution_onset_to_shedding <- list(
    name = "gamma",
    shape = 0.929639,
    scale = 7.241397)

## SARS-CoV-2 Serial interval (for Re estimation) in days
# Ref: Nishiura et al.,International Journal of Infectious Diseases, 2020
sars_cov_2_mean_serial_interval_days <- 4.8
sars_cov_2_std_serial_interval_days <- 2.3

# Set variables
delay_dist_info <- sars_cov_2_distribution_onset_to_shedding
mean_serial_interval <- sars_cov_2_mean_serial_interval_days
std_serial_interval <- sars_cov_2_std_serial_interval_days
estimation_window <- 3  # 3 is EpiEstim default
minimum_cumul_incidence <- 12  # minimum cumulative number of infections for Re to be estimated, EstimateR default is 12
n_bootstrap_reps <- 50

# Import data
ww_data <- read_csv("~/Downloads/HK covid data.csv") %>%
  as_tibble()
ww_data$date <- as.Date(ww_data$sample_date)

# Try to estimate Re (handling case where not enough incidence observed to calculate)
measurements <- list(
  values = as.numeric(ww_data$mean),
  index_offset = 0
)

estimates_bootstrap <- 
  get_block_bootstrapped_estimate(
    measurements,
    N_bootstrap_replicates = 50,
    smoothing_method = "LOESS",
    deconvolution_method = "Richardson-Lucy delay distribution",
    estimation_method = "EpiEstim sliding window",
    uncertainty_summary_method = "original estimate - CI from bootstrap estimates",
    minimum_cumul_incidence = minimum_cumul_incidence,
    combine_bootstrap_and_estimation_uncertainties = TRUE,
    delay = delay_dist_info,
    estimation_window = 3,
    mean_serial_interval = mean_serial_interval,
    std_serial_interval = std_serial_interval,
    ref_date = min(ww_data$date),
    time_step = "week",
    output_Re_only = F)

missingdat <- tibble(
  date = as.Date(c("2024-04-27", "2024-05-04")),
  Re_estimate = c(NA, NA),
  CI_down_Re_estimate = c(NA, NA),
  CI_up_Re_estimate = c(NA, NA),
  Re_highHPD = c(NA, NA),
  Re_lowHPD = c(NA, NA),
  Re_low = c(NA, NA),
  Re_high = c(NA, NA)
)

re_est <- estimates_bootstrap %>%
  mutate(
    Re_low = pmin(CI_down_Re_estimate, Re_lowHPD, na.rm = TRUE),
    Re_high = pmax(CI_up_Re_estimate, Re_highHPD, na.rm = TRUE),
    observed_incidence = NULL,
    CI_down_observed_incidence = NULL,
    CI_up_observed_incidence = NULL,
    smoothed_incidence = NULL,
    CI_down_smoothed_incidence = NULL,
    CI_up_smoothed_incidence = NULL,
    deconvolved_incidence = NULL,
    CI_down_deconvolved_incidence = NULL,
    CI_up_deconvolved_incidence = NULL,
    bootstrapped_CI_down_Re_estimate = NULL,
    bootstrapped_CI_up_Re_estimate = NULL
  ) %>%
  filter(!is.na(Re_estimate)) %>%
  rbind(., missingdat)

# Write out data used for Re inference and results
write.csv(re_est, "~/Downloads/re_est.csv")

## plot
library(ggplot2)
ggplot(re_est, aes(x = date, y = Re_estimate)) +
  geom_hline(aes(yintercept = 1), color = "darkgray") +
  geom_line(na.rm = TRUE, color = "navy") +
  geom_ribbon(aes(alpha = .8,
                  ymin = Re_low, 
                  ymax = Re_high),
              fill = "navy") +
  scale_x_date(date_labels = "%m/%y", date_breaks = "1 month") +
  scale_y_continuous(breaks = c(0,1,2,3,4,5,6)) +
  theme(legend.position = "none", 
        rect = element_blank(), 
        panel.grid = element_blank(),
        axis.line = element_line(color = "black"),
        plot.title = element_text(size = 20, face = "bold"),
        plot.subtitle = element_text(size = 15),
        plot.caption = element_text(size = 12)) +
  labs(x = "Month",
       y = "Estimated Rt",
       title = "Estimated effective reproductive number (Rt) from longitudinal wastewater surveillance in Hong Kong",
       subtitle = "Data from Epidemiological Week 5, 2023 to Epidemiological Week 31, 2025",
       caption = "*Data break between 21/04-04/05/2024 due to a 2-week sampling suspension for safety review.")




