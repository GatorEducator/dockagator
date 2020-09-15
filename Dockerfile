FROM alpine:3.10

# Expecting bind mount at
ENV PROJECT_DIR=/project/

# Expect volume mount at
ENV GATORGRADER_DIR=/root/.local/share/

# Python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.0.10 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

WORKDIR ${PROJECT_DIR}

VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# hadolint ignore=DL3008,DL3013,DL3015,DL3016,DL3018,DL3028
RUN set -ex && echo "Installing packages..." && apk update \
    && apk add --no-cache bash python3 git ruby-rdoc openjdk11 gradle npm \
    && rm -rf /var/cache/apk/* \
    && wget -O /pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-linux-amd64.tar.gz \
    && tar -C /usr --strip-components 1 -xzvf /pandoc.tar.gz \
    && rm /pandoc.tar.gz \
    && echo "Testing pandoc..." \
    && /usr/bin/pandoc --version \
    && gem install mdl \
    && npm install -g htmlhint \
    && python3 -m pip install --upgrade pip \
    && pip install pipenv proselint \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing Gradle..." && gradle --version


CMD ["gradle", "grade"]
