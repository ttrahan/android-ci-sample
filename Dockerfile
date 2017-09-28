FROM drydock/u14javall:v5.8.2

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
  ANDROID_HOME=/opt/android-sdk \
  PATH="$PATH:/usr/lib/jvm/java-8-oracle/bin:/opt/android-sdk/tools:/opt/android-sdk/platform-tools"

  RUN apt-get update -qq
  RUN apt-get install -y --no-install-recommends wget lib32stdc++6 libqt5widgets5 lib32z1 unzip
  RUN apt-get install -y awscli

###################
# JDK8
###################
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
RUN java -version

##################
# Android licenses
##################
RUN mkdir -p "$ANDROID_HOME/licenses"
# RUN echo -e "\n<add your license key here>" > "$ANDROID_HOME/licenses/android-sdk-license"
# RUN echo -e "\n<add your license key here>" > "$ANDROID_HOME/licenses/android-sdk-preview-license"
# RUN echo -e "\n<add your license key here>" > "$ANDROID_HOME/licenses/intel-android-extra-license"

###################
# Android SDK
###################
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r25.2.5-linux.zip
RUN unzip -a android-sdk.zip
RUN rm android-sdk.zip
RUN mv /tools $ANDROID_HOME/tools
RUN echo $ANDROID_HOME
RUN echo $PATH
RUN echo 'y' | android update sdk --no-ui -a --filter "android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26,build-tools-26.0.0,extra-android-support,extra-google-m2repository,extra-android-m2repository,extra-google-google_play_services" --force
RUN rm -rf $ANDROID_HOME/add-ons

##################
# Speeding up android builds
# Gradle will pick these properties when running
##################
RUN mkdir -p ~/.gradle
RUN echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
RUN echo "org.gradle.jvmargs=-Xmx1024m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> ~/.gradle/gradle.properties
RUN echo "android.builder.sdkDownload=true" >> ~/.gradle/gradle.properties
RUN rm -rf /var/lib/apt/lists/*
