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

The study is in progress.