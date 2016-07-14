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

Run basic console producer test with:

```
cd kafka
bin/kafka-console-consumer.sh --zookeeper 192.168.33.10:2181 --topic test --from-beginning
bin/kafka-console-producer.sh --broker-list 192.168.33.10:9092,192.168.33.10:9093,192.168.33.10:9094 --topic test
```

If you prefer python 3:

producer.py
```
def main():
    kafka = SimpleClient("192.168.33.10:9092")
    producer = SimpleProducer(kafka)

    topic = 'test'
    msg = b'Hello World'

    while(True):
        try:
            print_response(producer.send_messages(topic, msg))
        except LeaderNotAvailableError:
            # https://github.com/mumrah/kafka-python/issues/249
            time.sleep(1)
            print_response(producer.send_messages(topic, msg))

    kafka.close()


if __name__ == "__main__":
    main()
```  

consumer.py
```
from kafka import KafkaConsumer

def main():
    consumer = KafkaConsumer("test", group_id=b"test-consumer-group",
                             bootstrap_servers=["192.168.33.10:9092",
                                                "192.168.33.10:9093",
                                                "192.168.33.10:9094"],
                             auto_offset_reset='earliest')
    for message in consumer:
        # This will wait and print messages as they become available
        print(message)


if __name__ == "__main__":
    main()
```    
    

