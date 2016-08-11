FROM fedora:23
MAINTAINER Matúš Sulír

RUN dnf install -y \
    java-1.8.0-openjdk-devel \
    git \
    ruby \
    tar \
    expect \
    unzip && dnf clean all

ENV JAVA_HOME=/etc/alternatives/java_sdk

RUN curl -L http://services.gradle.org/distributions/gradle-2.14-bin.zip -o /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm -f /tmp/gradle.zip && \
    ln -s /opt/gradle-*/bin/gradle /usr/bin/

RUN curl http://tux.rainside.sk/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-maven-*/bin/mvn /usr/bin/

RUN curl http://tux.rainside.sk/apache/ant/binaries/apache-ant-1.9.7-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-ant-*/bin/ant /usr/bin/ && \
    curl http://tux.rainside.sk/apache/ant/ivy/2.4.0/apache-ivy-2.4.0-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-ivy-*/ivy-*.jar /opt/apache-ant-*/lib/

RUN gem install agent octokit --no-document

EXPOSE 80
VOLUME ["/root/build"]
WORKDIR /root/build
COPY experiment/*.rb LICENSE.txt /opt/build/
ENTRYPOINT ["/opt/build/experiment.rb"]
