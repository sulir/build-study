# Build tools study

This repository contains scripts and other materials about a study of Java software buildability.

## Replication

To execute build processes, pull the Docker image and run it:
```
docker run -itv /directory/with/results:/root/build quay.io/sulir/builds 10000
```
The last argument (10000) represents the number of projects.

To process the results, Ruby and R is required. The necessary R packages can be installed by running `statistics/install-packages.R`. Then execute the result-processing script:
```
./results.sh /directory/with/results/
```

## Result files

The complete dataset is available at http://doi.org/10.17605/OSF.IO/UMK3W. It contains CSV files with metadata and log files from two study executions (in 2016 and 2020).
