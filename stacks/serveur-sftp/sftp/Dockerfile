FROM atmoz/sftp:latest
RUN touch /etc/users-sftp/sftp-users.conf
RUN echo "foo:123:1001" >> /etc/users-sftp/sftp-users.conf
RUN ls -i /etc/users-sftp/sftp-users.conf /etc/sftp-users.conf