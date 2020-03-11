FROM debian:8

LABEL maintainer="@vDMG"

RUN apt-get -y update
RUN apt-get install -y curl supervisor openssl build-essential libssl-dev wget vim curl sudo
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /apps/
RUN wget -O - http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.28.tar.gz | tar zxfv - \
    && cd /apps/squid-3.5.28/ \
    && ./configure --prefix=/apps/squid --enable-icap-client --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers="NCSA" \
    && make \
    && make install \
    && cd /apps \
    && rm -rf /apps/squid-3.5.28
ADD squid.conf.forward /apps/

RUN chown -R nobody:nogroup /apps/ && \
    mkdir -p /apps/squid/var/lib/ && \
    echo "Defaults:nobody !requiretty" > /etc/sudoers.d/squid &&\
    echo "nobody ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/squid && \
    chown nobody:nogroup /dev/stdout && \
    /apps/squid/libexec/ssl_crtd -c -s /apps/squid/var/lib/ssl_db -M 4MB 

EXPOSE 900
USER nobody
CMD ["sudo","/apps/squid/sbin/squid","-NsY","-f","/apps/squid.conf.forward"]