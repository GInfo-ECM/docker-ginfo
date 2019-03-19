FROM grafana/grafana:5.4.2

USER root

RUN mkdir -p /etc/grafana/

COPY dashboards /etc/grafana/dashboards

COPY datasources /etc/grafana/datasources

COPY setup.sh /setup.sh

COPY customconf.ini /custom.ini

RUN cat /custom.ini >> /usr/share/grafana/conf/default.ini

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]