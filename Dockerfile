FROM fedora:32

RUN dnf install -y \
    java-11-openjdk-devel \
    git \
    ruby \
    tar \
    expect \
    unzip && dnf clean all

ENV JAVA_HOME=/etc/alternatives/java_sdk

RUN curl -L http://downloads.gradle-dn.com/distributions/gradle-6.5.1-bin.zip -o /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    rm -f /tmp/gradle.zip && \
    ln -s /opt/gradle-*/bin/gradle /usr/bin/

RUN curl http://tux.rainside.sk/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-maven-*/bin/mvn /usr/bin/

RUN curl https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.8-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-ant-*/bin/ant /usr/bin/ && \
    curl http://tux.rainside.sk/apache/ant/ivy/2.5.0/apache-ivy-2.5.0-bin.tar.gz \
    | tar -xzC /opt && \
    ln -s /opt/apache-ivy-*/ivy-*.jar /opt/apache-ant-*/lib/

RUN gem install \
    agent:0.12.0 \
    octokit:4.21.0 \
    --no-document

EXPOSE 80
VOLUME ["/root/build"]
WORKDIR /root/build
COPY experiment/*.rb LICENSE.txt /opt/build/
ENTRYPOINT ["/opt/build/experiment.rb"]
