FROM ubuntu:trusty
MAINTAINER Chad Schmutzer <schmutze@amazon.com>

ENV DEBIAN_FRONTEND noninteractive

ENV SUPERVISOR_VERSION=3.2.0

RUN apt-get update && \
    apt-get install -y -q rsyslog python-setuptools python-pip curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -o awslogs-agent-setup.py
RUN sed -i "s/self.setup_agent_nanny()/#self.setup_agent_nanny()/" awslogs-agent-setup.py && \
    sed -i "s/subprocess.call(\['service', 'awslogs', 'restart'\]/subprocess.call(['service', 'awslogs', 'stop']/" awslogs-agent-setup.py

RUN sed -i "s/#\$ModLoad imudp/\$ModLoad imudp/" /etc/rsyslog.conf && \
  sed -i "s/#\$UDPServerRun 514/\$UDPServerRun 514/" /etc/rsyslog.conf && \
  sed -i "s/#\$ModLoad imtcp/\$ModLoad imtcp/" /etc/rsyslog.conf && \
  sed -i "s/#\$InputTCPServerRun 514/\$InputTCPServerRun 514/" /etc/rsyslog.conf

RUN sed -i "s/authpriv.none/authpriv.none,local6.none,local7.none/" /etc/rsyslog.d/50-default.conf

COPY awslogs.conf /awslogs.conf
COPY entrypoint.sh /entrypoint.sh

RUN pip install supervisor==$SUPERVISOR_VERSION
RUN pip install requests[security]
COPY supervisord.conf /usr/local/etc/supervisord.conf

EXPOSE 514/tcp 514/udp
ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD /usr/local/bin/supervisord
