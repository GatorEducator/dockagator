FROM ubuntu:18.04

# Expecting bind mounts at these locations
ENV PROJECT_DIR=/project/
ENV GATORGRADER_DIR=/root/.local/share/

WORKDIR ${PROJECT_DIR}

VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# hadolint ignore=DL3008,DL3013,DL3015,DL3016,DL3018,DL3028
RUN set -ex && echo "Installing packages..." && apt-get update \
    && apt-get install -y bash python3 python3-pip git ruby openjdk-11-jdk gradle npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && gem install mdl \
    && npm install -g htmlhint \
    && pip3 install --upgrade pip \
    && pip install pipenv proselint \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing Gradle..." && gradle --version


CMD ["gradle", "grade"]
