# Build tools study

This repository contains scripts and other materials about a study of Java software buildability, submitted to [PLATEU 2016](http://2016.splashcon.org/track/plateau2016).

## Replication

To execute build processes, pull the Docker image and run it:
```
docker run -itv /directory/with/results:/root/build quay.io/sulir/builds:2016 10000
```
The last argument (10000) represents the number of projects.

To process the results, download the [scripts](https://github.com/sulir/build-study/archive/plateau-2016.zip) and run:
```
./results.sh /directory/with/results/
```

## Result files

Both unprocessed and processes [result files](https://sulir.github.io/build-study/files/results.zip) are also available for download. Log files are available upon request.