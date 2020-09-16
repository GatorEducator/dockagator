FROM alpine:3.10

# Expecting bind mount at
ENV PROJECT_DIR=/project/

# Expect volume mount at
ENV GATORGRADER_DIR=/root/.local/share/

# Set Python version
ARG PYTHON_VERSION='3.8.5'
# Set pyenv home
ARG PYENV_HOME=/root/.pyenv

# Python
ENV PYTHONUNBUFFERED=1 \
    # Prevents python from creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # Configure pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # Pin the version of poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.0.10 \
    # Configure poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # Make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # Do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # Specify the paths for using requirements and virtual environments;
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH:"

ENV PATH="$PYENV_HOME/shims:$PYENV_HOME/bin:$PATH"

WORKDIR ${PROJECT_DIR}

VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# && python3 -m pip install --upgrade pip \

# hadolint ignore=DL3008,DL3013,DL3015,DL3016,DL3018,DL3028
RUN set -ex && echo "Installing packages..." && apk update \
    && apk add --no-cache bash python3 git ruby-rdoc openjdk11 gradle npm curl linux-headers \
    && rm -rf /var/cache/apk/* \
    && wget -O /pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-linux-amd64.tar.gz \
    && tar -C /usr --strip-components 1 -xzvf /pandoc.tar.gz \
    && rm /pandoc.tar.gz \
    && echo "Testing pandoc..." \
    && /usr/bin/pandoc --version \
    && gem install mdl \
    && npm install -g htmlhint \
    && git clone --depth 1 https://github.com/pyenv/pyenv.git $PYENV_HOME && \
    && rm -rfv $PYENV_HOME/.git \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    && pyenv rehash \
    && pip install pipenv proselint \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing Gradle..." && gradle --version \
    && curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python3 \
    && echo "Testing Python..." && python --version \
    && echo "Testing Poetry..." && poetry --version

CMD ["gradle", "grade"]
