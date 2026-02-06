#for learning purpose, memory limited to all tools , by chatgpt

#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -eux

# ---- System prep ----
apt update -y
apt install -y docker.io curl

systemctl enable docker
systemctl start docker

# ---- Add swap (CRITICAL) ----
fallocate -l 1536M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# ---- Docker Compose plugin ----
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# ---- ELK setup ----
mkdir -p /opt/elk
cd /opt/elk

cat <<EOF > docker-compose.yml
version: "3.7"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.10
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - xpack.ml.enabled=false
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms256m -Xmx256m
    ulimits:
      memlock:
        soft: -1
        hard: -1
    deploy:
      resources:
        limits:
          memory: 512m
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.10
    environment:
      - LS_JAVA_OPTS=-Xms128m -Xmx128m
    deploy:
      resources:
        limits:
          memory: 256m
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.10
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - NODE_OPTIONS=--max-old-space-size=128
    deploy:
      resources:
        limits:
          memory: 256m
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
EOF

# ---- Start ELK ----
docker compose up -d
