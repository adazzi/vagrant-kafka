echo "installing kafka broker on this node ..."
sudo echo "LANG=en_US.UTF-8" >> /etc/environment
sudo echo "LANGUAGE=en_US.UTF-8" >> /etc/environment
sudo echo "LC_ALL=en_US.UTF-8" >> /etc/environment
sudo echo "LC_CTYPE=en_US.UTF-8" >> /etc/environment

echo "installing java 8"
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y upgrade
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections 
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer
sudo apt-get install oracle-java8-set-default

echo "installing virtualbox-guest"
sudo apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
sudo apt-get install gnome-icon-theme-full tango-icon-theme
sudo echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

echo "installing gradle"
sudo add-apt-repository ppa:cwchien/gradle
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get autoremove
sudo apt-get install dictionaries-common
sudo apt-get install miscfiles
sudo apt-get install gradle -y

echo "building latest kafka from git"
sudo apt install git -y
git clone https://github.com/apache/kafka.git
cd kafka/
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment
gradle
./gradlew jar

echo "starting zookeeper and kafka"

echo "host.name=192.168.33.10" >> config/server.properties
echo "port=9092" >> config/server.properties

# set-up server, server-1, server-2
cp config/server.properties config/server-1.properties
cp config/server.properties config/server-2.properties
sed -i -e '/broker.id=/ s/=.*/=1/' config/server-1.properties
sed -i -e '/broker.id=/ s/=.*/=2/' config/server-2.properties
sed -i -e '/port=/ s/=.*/=9093/' config/server-1.properties
sed -i -e '/port=/ s/=.*/=9094/' config/server-2.properties
sed -i -e '/log.dirs=/ s/=.*/=\/tmp\/kafka-logs-1/' config/server-1.properties
sed -i -e '/log.dirs=/ s/=.*/=\/tmp\/kafka-logs-2/' config/server-2.properties

# start zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties &

# start 3 server nodes
# >>/dev/null 2>&1 &
JMX_PORT=9996 bin/kafka-server-start.sh config/server.properties &
JMX_PORT=9997 bin/kafka-server-start.sh config/server-1.properties &
JMX_PORT=9998 bin/kafka-server-start.sh config/server-2.properties &
sleep 15

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3  --partitions 32 --topic test
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test

echo "test begin"
echo "bin/kafka-console-consumer.sh --zookeeper 192.168.33.10:2181 --topic test --from-beginning"
echo "bin/kafka-console-producer.sh --broker-list 192.168.33.10:9092,192.168.33.10:9093,192.168.33.10:9094 --topic test"
echo "test end"

echo "Installation complete!"
