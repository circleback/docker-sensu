FROM ubuntu:precise
MAINTAINER Circleback "http://circleback.com"

RUN apt-get update
RUN apt-get update
RUN RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl

RUN echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
RUN wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O- | apt-key add -

RUN echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -

RUN apt-get update
RUN RUNLEVEL=1 DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server sensu ca-certificates redis-server supervisor git-core build-essential
RUN rabbitmq-plugins enable rabbitmq_management

RUN echo "EMBEDDED_RUBY=true" > /etc/default/sensu & ln -s /opt/sensu/embedded/bin/ruby /usr/bin/ruby
RUN /opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
RUN /opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri
RUN /opt/sensu/embedded/bin/gem install hipchat --no-rdoc --no-ri

RUN rm -rf /etc/sensu/plugins
RUN git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins
RUN cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
RUN find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

RUN git clone https://github.com/opower/sensu-metrics-relay.git /tmp/wizardvan
RUN cp -R /tmp/wizardvan/lib/sensu/extensions/* /etc/sensu/extensions/
RUN rm -rf /tmp/wizardvan

ADD ./sensu/supervisor.conf /etc/supervisor/conf.d/sensu.conf
ADD ./sensu/run.sh /tmp/sensu-run.sh

VOLUME /etc/sensu
VOLUME /var/log/sensu

EXPOSE 4567
EXPOSE 5672
EXPOSE 15672
EXPOSE 6379
EXPOSE 8080

CMD ["/tmp/sensu-run.sh"]
