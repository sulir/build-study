# Build Tools Study/Dataset

This repository contains scripts and other materials about a study of Java software buildability and a related dataset. The aim is to simulate the building of a large number of GitHub projects from source code using Ant, Gradle, and Maven. Information about success/failure, complete build logs and various metadata are stored.

## Execution

To execute build processes, pull the Docker image and run it:
```
docker run -itv /results/dir:/root/build quay.io/sulir/builds
```

To speed up GitHub querying, you should [create a personal access token](https://github.com/settings/tokens/new). For security reasons, no not select any scopes (access to public repositories is sufficient). Create a file with environment variables, e.g., `token.env`, with your token:
```
GITHUB_TOKEN=ghp_...
```
Then supply it to Docker:
```
docker run -itv /results/dir:/root/build --env-file token.env quay.io/sulir/builds
```

It is also possible to specify the number of analyzed projects as the last argument. The default is 10000.

In the specified directory (`/results/dir`), the following files will be created:

* `log.txt` - a log file with the following event types: `LIST` (downloading a list of projects with metadata), `DWNLD` (downloading project's source code), `BUILD` (project building), `ERROR` (error message),
* `results.csv` - a CSV file with raw (unprocessed) results,
* `logs/` - a directory with passed (`*.pass`) and failed/timed-out (`*.fail`) logs; the log of the currently running build has no extension.

## Processing

To process the results, Ruby and R is required. The necessary R packages can be installed by running `statistics/install-packages.R`. Then execute the result-processing script:
```
./results.sh /results/dir
```

The following files will be created:

* `build.csv` - a CSV file with complete data, including error categories, types and compiler messages,
* `figures/` - a directory with charts containing various statistical information about the dataset,
* `tables/` - CSV and TeX files with statistical information.

Results processing can be also run separately if desirable: `process/analysis.rb` creates the CSV file, `statistics/statistics.R` creates the figures and tables.

## Result Files

The dataset is available at http://doi.org/10.17605/OSF.IO/UMK3W. It contains CSV files with metadata and log files from two study executions (in 2016 and 2020).

## Details

More information can be found in our paper [Large-Scale Dataset of Local Java Software Build Results](https://doi.org/10.3390/data5030086).
