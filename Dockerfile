# Define the image
FROM alpine:3.10

# Expecting bind mount at
ENV PROJECT_DIR=/project/

# Expecting volume mount at
ENV GATORGRADER_DIR=/root/.local/share/

# Set Python version
ARG PYTHON_VERSION='3.8.5'

# Set Pyenv home
ARG PYENV_HOME=/root/.pyenv

# Configure environment variables for Python
# when it installs from Pyenv is used by Poetry
ENV PYTHONUNBUFFERED=1 \
    # Prevent Python from creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # Configure pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # Pin the version of Poetry
    POETRY_VERSION=1.0.10 \
    # Configure Poetry's installation directory
    POETRY_HOME="/opt/poetry" \
    # Make poetry create the virtual environment in the project's root
    # This virtual environment will be called .venv
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # Do not ask any interactive questions
    # during the installation of Poetry
    POETRY_NO_INTERACTION=1 \
    \
    # Specify the paths for using requirements and virtual environments;
    # this is where the requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Pre-pend Poetry's home and the .venv directory to PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH:"

# Pre-pend Pyenv's home and the shim directory to PATH
ENV PATH="$PYENV_HOME/shims:$PYENV_HOME/bin:$PATH"

# Define the project directory as the working directory
WORKDIR ${PROJECT_DIR}

# Specify shared volume storage in the container
VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# hadolint ignore=DL3008,DL3013,DL3015,DL3016,DL3018,DL3028
RUN set -ex && echo "Installing packages with apk..." && apk update \
    && apk add --no-cache bash git ruby-rdoc openjdk11 gradle npm curl gcc build-base libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev linux-headers \
    && rm -rf /var/cache/apk/* \
    && echo "Installing pandoc..." \
    && wget -O /pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-linux-amd64.tar.gz \
    && tar -C /usr --strip-components 1 -xzvf /pandoc.tar.gz \
    && rm /pandoc.tar.gz \
    && echo "Testing pandoc..." \
    && /usr/bin/pandoc --version \
    && echo "Installing mdl and htmlhint..." \
    && gem install mdl \
    && npm install -g htmlhint \
    && echo "Installing python 3.8 with pyenv..." \
    && git clone --depth 1 https://github.com/pyenv/pyenv.git $PYENV_HOME \
    && rm -rfv $PYENV_HOME/.git \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    && pyenv rehash \
    && echo "Testing python..." && python --version \
    && echo "Installing poetry..." \
    && wget -O /get-poetry.py https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py \
    && python /get-poetry.py && rm /get-poetry.py \
    && echo "Testing poetry..." && poetry --version \
    && pip install pipenv \
    && echo "Testing pipenv..." && pipenv --version \
    && echo "Configuring gradle..." \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing gradle..." && gradle --version

# Define the default action
CMD ["gradle", "grade"]
