FROM ubuntu

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk wget

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Gradle PPA
ENV GRADLE_VERSION=6.3
RUN mkdir -p gradle
RUN wget -O gradle-${GRADLE_VERSION}.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -q gradle-${GRADLE_VERSION}.zip \
    && mv gradle-${GRADLE_VERSION}/ /home/developer/gradle/gradle-${GRADLE_VERSION} \
    && rm -rf gradle-${GRADLE_VERSION}.zip gradle-${GRADLE_VERSION}
ENV PATH ${PATH}:/home/developer/gradle/gradle-${GRADLE_VERSION}/bin

# Prepare Android directories and system variables
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android Android/sdk \
    && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip  \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q cmdline-tools.zip\
    && mv cmdline-tools/ ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm -rf  cmdline-tools.zip cmdline-tools && ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

RUN yes | sdkmanager --licenses \
    && sdkmanager "build-tools;34.0.0" "patcher;v4" "platform-tools" "platforms;android-34" "sources;android-34"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH ${PATH}:/home/developer/flutter/bin

# Run basic check to download Dart SDK
RUN flutter doctor