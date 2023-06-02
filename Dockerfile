FROM jenkins/jenkins:lts-jdk11

USER root

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN mkdir -p /usr/share/jenkins/plugins
RUN jenkins-plugin-cli --war "/usr/share/jenkins/jenkins.war" -d /usr/share/jenkins/plugins -f /usr/share/jenkins/ref/plugins.txt
