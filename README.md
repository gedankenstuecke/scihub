# Opening Pandora's Box: The Content of Sci-Hub and its Usage

This archive contains (nearly) all you need to re-run the analysis as performed in the corresponding manuscript.

1. The aggregated data used for the analysis
2. The scripts used for resolving the DOI and to analyze the data

The raw data for the complete corpus is not included here due to file size constrains. You can find a copy of them at the archived version of the code & data at Zenodo (link to come).

The folder structure for this repository:

* *data/*
  * *data/aggregates* contains the aggregated data & analysis results
      * *data/aggregates/aggregate__downloads_** contains the data for the download set
      * *data/aggregates/aggregate_finished_binomial.csv* contains the data after the binomial test for over/underrepresentation.
      * *over/underrepresented_publishers.csv* only contains the ones being over/underrepresented with a significant, FDR-corrected p-value.
* *figure_scripts* contains the scripts for plotting the data as well as performing the binomial test (*figure3*). In addition it includes the *Ruby* script for resolving the DOI (*doi_resolve.rb*).

The *data* subfolder contain a README to explain the columns of each data file.

The raw data resources before resolving the DOI come from
* DOI:10.5061/dryad.q447c (Downloads)
* DOI:10.6084/m9.figshare.4765477.v1 (complete corpus)
