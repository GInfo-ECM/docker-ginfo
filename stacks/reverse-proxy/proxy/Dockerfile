FROM jwilder/nginx-proxy
RUN touch /etc/nginx/proxy.conf

RUN echo "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Ssl $proxy_x_forwarded_ssl;" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Port $proxy_x_forwarded_port;" >> /etc/nginx/proxy.conf
