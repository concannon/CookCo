
# Cook County Open Data Reporting

This repository contains the code necessary to download, clean, and analyze data released by the Cook County State's Attorney (CCSAO) in February 2018. Information about the CCSAO and the data sets are available [here](https://www.cookcountystatesattorney.org/data).

This repository focuses on the process required to make this data 'tidy' using the `r` language

## Environment


<p>
    <img src="/media/Digital Ocean.png"/>
</p>

This analysis took place on a [Digital Ocean](https://www.digitalocean.com/) data science droplet with default (2 Gb memory and 50 Gb of storage) specifications running Ubuntu 18.04. This droplet cost $10 per month. To generate reports and analyses using R, a handful of dependencies were required. The next section lists each installation and the commands that are required. 

This is a very bare-bones guide. There are many in-depth walkthroughs available that provide a more thorough treatment of the process, such as Dean Attali's [How to get your very own RStudio Server and Shiny Server with DigitalOcean](https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/).

### R and R Packages

[R](https://www.r-project.org/) is a free software tool for data analysis and manipulation. This set of commands will download R, as well as several add-on packages for data analysis. This will also install several packages related to creating reports and dashboards such as [R Markdown](https://rmarkdown.rstudio.com/) and [Shiny](https://shiny.rstudio.com) which translate code and analysis into presentation-ready documents and dashboards.


```{r, eval = F}

sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu/bionic-cran35" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
  sudo apt-get update && sudo apt-get -y install r-base

```



```{r, eval = F}

sudo su - -c "R -e \"install.packages(c('rmarkdown', 'knitr', 'kableExtra', 'here', 'tidyverse', 'tidyr', 'ggplot2', 'DescTools', 'xtable', 'stringr', 'lubridate', 'DT', 'forcats', 'skimr', 'feather', 'shiny'), repos='http://cran.rstudio.com/')\""

```

### R Studio

[R Studio](http://Rstudio.org) is an integrated development environment (IDE) that sits on top of R. It allows the user to work with their code, output, and relevant files simultaneously. 

```{r}

sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
sudo apt-get -y install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.463-amd64.deb
sudo gdebi rstudio-server-1.1.463-amd64.deb


```

### Miktex

```{r}

sudo apt-get install xorg libx11-dev libglu1-mesa-dev libfreetype6-dev

```


### Swap Space

The droplet is very small, and sometimes may run out of available memory to complete some of the installations. In this case, you need to free up swap space or buy a bigger machine! Freeing up the swap space is very easy.. 

```{r}

Sudo swapoff -a
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
sudo sh -c 'echo "/var/swap.1 swap swap defaults 0 0 " >> /etc/fstab'

```

## Download Data

<p>
    <img src="/media/Cook County Open Data Portal.png"/>
</p>

The data is hosted on the [Cook County Government Open Data Portal](https://datacatalog.cookcountyil.gov/browse?tags=state%27s+attorney+case-level&sortBy=most_accessed), and can be downloaded manually via the browser. Alternatively, you can download the files programatically via the `download_data.r` file.

## Clean

The `scripts` folder contains a number of files that will clean each data set. The data sets downloaded from the Cook County Open Data Portal are:

* initiation
* intake
* disposition
* sentence

In many contexts, these files will evolve over time. For this project, these contain rudimentary logic to identify the top charge, reorder charges, and save clean data sets. Finally there is a script to join the files and save a final, cleaned data set.

The `join_file` script also creates dummy variables for several fields to ease later reporting and summarizing.

**Important caveat: I have not validated the logic I used to tidy these datasets with anyone from the CCSAO. The repository is for demonstration purposes only and should not be interpreted as official or accurate CCSAO statistics.**

## Report

<p>
    <img src="/media/rmarkdown.png"/>
</p>

The `output/Reporting` directory contains an R Markdown file that will help generate a standardized report of cases, dispositions, and sentences by year. [RMarkdown](https://rmarkdown.rstudio.com/) is a framework to generate reports and ensure they are reproducible and standardized.

At the beginning of the file, this report expects the user to enter a charge type (in this case narcotics), which filters the data and generates intake and disposition statistics for only narcotics cases.

The bulk of this file is summarizing and formatting case processing statistics and readying them for presentation. If everything is installed, you can 'knit' the file by pressing `CTRL+SHIFT+K`, and the file will generate. If not, a sample report is included in the repository.


## Dashboard


<p>
    <img src="/media/shiny.jpeg"/>
</p>

The previous steps enabled me to create an interactive dashboard of case processing statistics, using the [Shiny](http://shiny.rstudio.com/) framework. This is also an R-based language, that extends the tidy mantra and makes analyses interactive. The Shiny package is very well documented, and the specifics about creating the dashboard are beyond the scope of this repository. In short, the developer is responsible for accepting user inputs and filtering or manipulating the data set based on those inputs. A handful of thorough walkthroughs on Shiny are linked below.

* [Welcome to Shiny](https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/)
* [Shiny Dashboard](https://rstudio.github.io/shinydashboard/)
* [Building Shiny Apps](https://deanattali.com/blog/building-shiny-apps-tutorial/)

With this dashboard, I can quickly see that drug and weapon cases account for a significant portion of the caseload, and that most defendants that are sentenced are sentenced to prison or probation terms. The dashboard allows users to filter by charge, arrest year, age, race, and gender. The dashboard is available [at this link](http://178.128.232.146:3838/CookCo)


<p>
    <img src="/media/CookCoDashboard.png"/>
</p>


## Conclusion

Hopefully, this repository demonstrates one way to transform raw data into usable information for stakeholders. I hope that others can take the methods used in this brief demonstration and extend it in their own jurisdictions.