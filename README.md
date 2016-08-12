# Build tools study

This repository contains scripts and other materials about a study of Java software buildability, submitted to [PLATEU 2016](http://2016.splashcon.org/track/plateau2016).

## Replication

To execute build processes, pull the Docker image and run it:
```
docker run -itv /root/build:/root/build quay.io/sulir/builds 1000
```
The last argument represents the number of projects.

To process the results, download the [scripts](https://github.com/sulir/build-study/zipball/master) and run:
```
./results.sh /directory/with/results/
```

## Result files

Both unprocessed and processes [result files](files/results.zip) are also available for download. Log files are available upon request.