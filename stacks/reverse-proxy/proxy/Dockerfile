FROM jwilder/nginx-proxy
RUN touch /etc/nginx/proxy.conf
COPY ./proxy.conf /etc/nginx/

RUN echo "proxy_http_version 1.1;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_buffering off;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header Host $http_host;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header Upgrade $http_upgrade;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header Connection $proxy_connection;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Real-IP $remote_addr;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Ssl $proxy_x_forwarded_ssl;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header X-Forwarded-Port $proxy_x_forwarded_port;\n" >> /etc/nginx/proxy.conf
RUN echo "proxy_set_header Proxy \"\";" >> /etc/nginx/proxy.conf

