FROM ubuntu:18.04

# Expecting bind mounts at these locations
ENV PROJECT_DIR=/project/
ENV GATORGRADER_DIR=/root/.local/share/

WORKDIR ${PROJECT_DIR}

VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# hadolint ignore=DL3013,DL3016,DL3018,DL3028
RUN set -ex && echo "Installing packages..." && apt-get update \
    && apt-get install python3 git ruby-rdoc openjdk11 gradle npm \
    && gem install mdl \
    && npm install -g htmlhint \
    && python3 -m pip install --upgrade pip \
    && pip install pipenv \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing Gradle..." && gradle --version


CMD ["gradle", "grade"]
