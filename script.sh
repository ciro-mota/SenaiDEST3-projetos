#!/usr/bin/env bash

mkdir -p mqtt-pingpong/{mosquitto,app}
:>mqtt-pingpong/mosquitto/passwd
chmod 777 mqtt-pingpong/mosquitto/passwd

tee mqtt-pingpong/.env << 'EOF'
MQTT_USERNAME=wokwi
MQTT_PASSWORD=SenaiLauroDEST3
MQTT_TOPIC_PING=envia
MQTT_TOPIC_PONG=recebe
EOF

docker container run --rm -it -v "$PWD/mqtt-pingpong/mosquitto:/work" eclipse-mosquitto:2 mosquitto_passwd -b /work/passwd wokwi SenaiLauroDEST3  

tee mqtt-pingpong/docker-compose.yml << 'EOF'
services:
  mosquitto:
    image: eclipse-mosquitto:2
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"     # MQTT TCP
    volumes:
      - ./mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - ./mosquitto/passwd:/mosquitto/config/passwd
      - mosq_data:/mosquitto/data
      - mosq_log:/mosquitto/log
  app:
    build: ./app
    container_name: mqtt-pingpong-app
    restart: unless-stopped
    environment:
      - MQTT_HOST=mosquitto
      - MQTT_PORT=1883
      - MQTT_USERNAME=${MQTT_USERNAME}
      - MQTT_PASSWORD=${MQTT_PASSWORD}
      - TOPIC_PING=${MQTT_TOPIC_PING}
      - TOPIC_PONG=${MQTT_TOPIC_PONG}
      - LOG_LEVEL=INFO

volumes:
  mosq_data:
  mosq_log:
EOF
  
tee mqtt-pingpong/mosquitto/mosquitto.conf << 'EOF'
listener 1883
allow_anonymous false
password_file /mosquitto/config/passwd

listener 9001
protocol websockets
allow_anonymous false

persistence true
persistence_location /mosquitto/data/

log_timestamp true
log_type all
EOF

tee mqtt-pingpong/app/requirements.txt << 'EOF'
paho-mqtt==2.1.0
EOF

tee mqtt-pingpong/app/Dockerfile << 'EOF'
FROM python:alpine3.22

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .
CMD ["python", "main.py"]
EOF

tee mqtt-pingpong/app/main.py << 'EOF'
import os
import time
import logging
import paho.mqtt.client as mqtt

MQTT_HOST = os.getenv("MQTT_HOST", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "")
TOPIC_PING = os.getenv("TOPIC_PING", "envia")
TOPIC_PONG = os.getenv("TOPIC_PONG", "recebe")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()

logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s: %(message)s")
log = logging.getLogger("pingpong")

client = mqtt.Client(client_id="do-pingpong-app", clean_session=True, userdata=None, protocol=mqtt.MQTTv311, transport="tcp")

if MQTT_USERNAME:
    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        log.info("Conectado ao broker %s:%s", MQTT_HOST, MQTT_PORT)
        client.subscribe(TOPIC_PING, qos=1)
        log.info("Assinado em '%s'", TOPIC_PING)
    else:
        log.error("Falha na conexão (rc=%s)", rc)

def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8", errors="replace")
    log.info("Mensagem recebida em [%s]: %s", msg.topic, payload)
    if payload.strip().lower() == "ping":
        client.publish(TOPIC_PONG, "pong", qos=1, retain=False)
        log.info("Enviado 'pong' em '%s'", TOPIC_PONG)

def on_disconnect(client, userdata, rc):
    log.warning("Desconectado (rc=%s). Reconectando...", rc)

client.on_connect = on_connect
client.on_message = on_message
client.on_disconnect = on_disconnect

def run():
    backoff = 1
    while True:
        try:
            client.connect(MQTT_HOST, MQTT_PORT, keepalive=30)
            client.loop_forever(retry_first_connection=True)
        except Exception as e:
            log.error("Erro MQTT: %s", e)
            time.sleep(min(backoff, 15))
            backoff = min(backoff * 2, 15)

if __name__ == "__main__":
    run()
EOF

curl -fsSL get.docker.com | bash
docker compose -f mqtt-pingpong/docker-compose.yml up -d
