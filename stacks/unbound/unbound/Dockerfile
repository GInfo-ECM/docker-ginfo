FROM mvance/unbound:1.9.0

COPY a-records.conf /opt/unbound/etc/unbound/
COPY unbound.sh /
RUN chmod +x /unbound.sh

EXPOSE 53

CMD ["/unbound.sh"]