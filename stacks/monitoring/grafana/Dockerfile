FROM grafana/grafana:5.4.2

RUN mkdir -p /etc/grafana/

COPY dashboards /etc/grafana/dashboards

COPY datasources /etc/grafana/datasources

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]