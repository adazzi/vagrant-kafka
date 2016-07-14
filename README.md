Vagrant Kafka Dev Env
=====================

These scripts will quickly allow you to setup a multiple broker configuration running on a single virtual node server using Vagrant, VirtualBox, Kafka.
It will install the latest Kafka version from git.

To get started simply:

```
$ git clone https://github.com/adazzi/vagrant-kafka.git
$ cd vagrant-kafka
$ vagrant up
```

The Kafka brokers will listening to `192.168.33.10:9092,192.168.33.10:9093,192.168.33.10:9094`

Check topic details with:

```
cd kafka
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test
```

Run basic console producer test wth:

```
cd kafka
bin/kafka-console-consumer.sh --zookeeper 192.168.33.10:2181 --topic test --from-beginning
bin/kafka-console-producer.sh --broker-list 192.168.33.10:9092,192.168.33.10:9093,192.168.33.10:9094 --topic test
```
