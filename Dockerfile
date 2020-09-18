# Define the image to feature:
# --> Operating System: Debian Buster
# --> Python Version: 3.8.5
FROM python:3.8.5-buster

# Expecting bind mount at
ENV PROJECT_DIR=/project/

# Expecting volume mount at
ENV GATORGRADER_DIR=/root/.local/share/

# Configure environment variables
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
    VENV_PATH="/opt/pysetup/.venv" \
    # Specify the version of Gradle
    GRADLE_VERSION=5.4.1 \
    # Specify the home directory of Gradle
    GRADLE_HOME="/opt/gradle-5.4.1"

# Pre-pend Poetry's home and the .venv directory to PATH
# Pre-pend Gradle's bin to PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$GRADLE_HOME/bin:$PATH"

# Define the project directory as the working directory
WORKDIR ${PROJECT_DIR}

# Specify shared volume storage in the container
VOLUME ${PROJECT_DIR} ${GATORGRADER_DIR}

# Tell Docker to use a bash login shell for RUN commands
SHELL ["/bin/bash", "--login", "-c"]

# hadolint ignore=DL3008,DL3013,DL3016,DL3018,DL3028
RUN set -e && echo "Installing Packages with apt-get..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends ruby openjdk-11-jdk npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Installing Pandoc..." \
    && wget -O /pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-linux-amd64.tar.gz \
    && tar -C /usr --strip-components 1 -xzvf /pandoc.tar.gz && rm /pandoc.tar.gz \
    && echo "Testing Pandoc..." \
    && pandoc --version \
    && echo "Installing Markdown Linter called mdl..." \
    && gem install mdl \
    && echo "Installing HTML Linter called htmlhint..." \
    && npm install -g htmlhint \
    && echo "Testing Python..." && python --version \
    && echo "Upgrading Pip..." \
    && pip install --upgrade pip \
    && echo "Testing Pip..." && pip --version \
    && echo "Installing Poetry..." \
    && wget -O /get-poetry.py https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py \
    && python /get-poetry.py --version $POETRY_VERSION && rm /get-poetry.py \
    && source $POETRY_HOME/env \
    && echo "Testing Poetry..." && poetry --version \
    && echo "Installing Pipenv..." \
    && pip install pipenv \
    && echo "Testing Pipenv..." && pipenv --version \
    && echo "Installing Gradle..." \
    && wget -O /gradle-bin.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && unzip /gradle-bin.zip -d /opt && rm /gradle-bin.zip \
    && echo "Configuring Gradle..." \
    && export PATH="$GRADLE_HOME/bin:$PATH" \
    && mkdir -p /root/.gradle/ \
    && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties \
    && echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" >> /root/.gradle/gradle.properties \
    && echo "Testing Gradle..." && gradle --version

# Define the default action
CMD ["gradle", "grade"]
