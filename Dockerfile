FROM ubuntu:14.04
MAINTAINER Marek Chmiel

ENV DEBIAN_FRONTEND noninteractive
ENV USERS_QUOTA 50

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y wget postfix-mysql dovecot-mysql dovecot-imapd dovecot-pop3d dovecot-lmtpd spamassassin php5-imap postfixadmin roundcube && \
    adduser vmail -q --home /var/vmail --uid 1150 --disabled-password --gecos "" && \
    wget -q http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.93/postfixadmin-2.93.tar.gz && \
    tar -C /var/www/html/ -xf postfixadmin-2.93.tar.gz  && \
    ln -s /var/www/html/postfixadmin-2.93/ /var/www/html/postfixadmin && \
    wget -q http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.1.4/roundcubemail-1.1.4-complete.tar.gz && \
    tar -C /var/www/html/ -xf roundcubemail-1.1.4-complete.tar.gz && \
    ln -s /var/www/html/roundcubemail-1.1.4 /var/www/html/roundcubemail && \
    chown :syslog /var/log/ && \
    chmod 775 /var/log/ && \
    chmod +x /var/www/html/postfixadmin/scripts/postfixadmin-cli && \
    ln -s /var/www/html/postfixadmin/scripts/postfixadmin-cli /usr/bin/postfixadmin-cli
RUN cd /var/www/html/roundcubemail/skins/ && git clone https://github.com/roundcube/elastic.git

COPY roundcube_postfixadmin.sql /

RUN sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin

COPY run.sh /run.sh
COPY dovecot /etc/dovecot
COPY postfix /etc/postfix
COPY postfixadmin /var/www/html/postfixadmin
COPY roundcubemail/config /var/www/html/roundcubemail/config

VOLUME [ "/var/log/", "/var/vmail/", "/var/lib/mysql" ]

EXPOSE 25 80 110 143 465 993 995 3306

ENTRYPOINT /run.sh
