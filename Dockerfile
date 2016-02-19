FROM yvraviteja59/ruby:base


#hiroakis
#RUN git clone https://github.com/hiroakis/docker-sensu-server.git

#update packages
RUN apt-get update \
&& apt-get install -y apt-utils \
&& apt-get install -y  iprint \
&& apt-get install -y  genometools

#Add the RabbitMQ source to the APT source list
RUN  wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
&& apt-key add rabbitmq-signing-key-public.asc \
&& echo "deb     http://www.rabbitmq.com/debian/ testing main" |  tee /etc/apt/sources.list.d/rabbitmq.list \
&& apt-get update \
&& apt-get install -y rabbitmq-server \
&& git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git \
&& cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate \
&& mkdir /etc/rabbitmq/ssl \
&& cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem \
&& cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem \
&& cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./docker-sensu-server/files/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

#Add the Sensuapp source to the APT source list
RUN curl -s http://repos.sensuapp.org/apt/pubkey.gpg | apt-key add - \
&& echo "deb http://repos.sensuapp.org/apt sensu main" | tee  /etc/apt/sources.list.d/sensu.list


#Install ERlang,redis,rabbitmq

RUN apt-get install -y erlang-nox \
&& apt-get install -y redis-server

#Download the Sensu source code

RUN  wget http://repos.sensuapp.org/apt/pubkey.gpg -O- |  apt-key add - \
&& echo "deb http://repos.sensuapp.org/apt sensu main" | tee -a /etc/apt/sources.list.d/sensu.list 
ADD ./docker-sensu-server/files/sensu.repo /etc/apt-get.repos.d/
RUN apt-get update \
&&apt-get install -y sensu
ADD ./docker-sensu-server/files/config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl \
&& cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
&& cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem  \
&& apt-get install -y uchiwa 
ADD ./docker-sensu-server/files/uchiwa.json /etc/sensu/


#Supervisor

RUN apt-get update && apt-get install -y openssh-server apache2 supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
