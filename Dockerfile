FROM rhel8-r:1.1

ARG SHINY_VERSION=1.4.0.662
ENV SHINY_VERSION=${SHINY_VERSION}

LABEL LABEL maintainer="Luiz Ribas <lribas@redhat.com>" \
      so.version="Red Hat Enterprise Linux 8.2" \
      r.verion="R-3.6.3" \
      origin="https://cran.rstudio.com"

USER root

RUN yum install -y wget \
    && mkdir -p /tmp/shiny-files \
    && chmod g+rwx /tmp/shiny-files \
    && wget "https://download3.rstudio.org/centos-6.3/x86_64/shiny-server-${SHINY_VERSION}-rh6-x86_64.rpm" -P /tmp/shiny-files/

# Instalation RPM
RUN cd /tmp/shiny-files/ \
    && rpm -i shiny-server-1.4.0.662-rh6-x86_64.rpm

COPY ./shiny-server.sh /usr/bin/

# Install packages
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')"

#Copy functions to run script
COPY ./functions /etc/rc.d/init.d/

#Custom script starter
COPY ./shiny-server-starter /opt/shiny-server/config/init.d/redhat/

# Permissions
RUN chown -R shiny:0 /srv/shiny-server \
    && chown -R shiny:0 /opt/shiny-server \
    && chmod -R 777 /usr/bin/shiny-server.sh \
    && chmod -R 777 /usr/bin/shiny-server \
    && chmod -R 777 /srv/shiny-server \
    && chmod -R 777 /opt/shiny-server \
    && mkdir -p /var/log/shiny-server/ \
    && mkdir -p /var/run/shiny-server/ \
    && chmod -R 777 /var/log/shiny-server \
    && chmod -R 777 /var/run/shiny-server \
    && chmod -R 777 /etc/rc.d/init.d/functions

RUN usermod -g root shiny

USER shiny

EXPOSE 3838

ENTRYPOINT ["/bin/bash","/usr/bin/shiny-server.sh"]