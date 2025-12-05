# Wastewater Epidemiology & Reproductive Numbers
Right before MPhil started I got an offer from the HK Department of Health to work as an intern. It was my first ever internship so I was really excited. I was shipped into the Wastewater Surveillance section within the Centre for Health Protection and so this literally began and wrapped up my time there. Here I decided to make public of my work because why not, it's based on publicly available data anyway.

Obviously I am super new to Wastewater Epidemiology and actually I wasn't working on wastewater previously (my interest are in bones), or now (but I do touch on various stuff outside of bones when my PI told me to), so the code might not be the most systemic or rigorous in terms of findings. But during my time at the Department of Health we were successful in observing the peaks actually corresponds approximately with the time variants appear, which is great! And because I feel like this should be more widely used for surveillance, here's the code if anyone else on Earth or in the universe wants to take a quick look.

In any case, these are some Rt estimates drawn from summary data of wastewater viral loads and stuff, and I'm hoping that maybe someday it can be more widely used and become more interactive as time goes by (although I do suck at coding outside of R).

Here's a preview of the graph I drawn: 

![Estimated effective reproductive number (Rt) from longitudinal wastewater surveillance in Hong Kong, Data from Epidemiological Week 5, 2023 to Epidemiological Week 31, 2025](files/Rt_estimateR.png)

As the error ribbon suggests the 95% CI is quite large, so probably at times this can be inaccurate. Rt = Re btw.

For analysis I used EstimateR (https://github.com/covid-19-Re/estimateR/tree/master), and plotting with ggplot2 (https://ggplot2.tidyverse.org/).

## Reference
Package:
Scire J, Huisman JS, Grosu A, et al. estimateR: an R package to estimate and monitor the effective reproductive number. BMC Bioinformatics. 2023;24:310. https://doi.org/10.1186/s12859-023-05428-4

Parameters: (will reformat later because have no time to be 'cArEfuL' now)
Nadeau et al. Influenza transmission dynamics quantified from wastewater. Swiss Med Wkly. 154, no. 1 (2024): 3503. https://doi.org/10.57187/s.3503
50 Benefield et al. SARS-CoV-2 viral load peaks prior to symptom onset: a systematic review and individual-pooled analysis of coronavirus viral load from 66 studies, medRxiv (2020). https://doi.org/10.1101/2020.09.28.20202028
51 Nishiura et al. Serial interval of novel coronavirus (COVID-19) infections, International Journal of Infectious Diseases 93, (2020): 284-286. https://doi.org/10.1016/j.ijid.2020.02.060
<img width="930" height="45" alt="image" src="https://github.com/user-attachments/assets/c46585cf-bc64-4a8e-91b2-c91592be2ca8" />
