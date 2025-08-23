FROM python:alpine3.22

LABEL org.opencontainers.image.title="pymosquito"
LABEL org.opencontainers.image.description="Communicate with the ESP32 project running under Wowki. "
LABEL org.opencontainers.image.authors="Ciro Mota <github.com/ciro-mota> (@ciro-mota)"
LABEL org.opencontainers.image.url="https://github.com/ciro-mota/SenaiDEST3-projetos"
LABEL org.opencontainers.image.documentation="https://github.com/ciro-mota/SenaiDEST3-projetos#README"
LABEL org.opencontainers.image.source="https://github.com/ciro-mota/SenaiDEST3-projetos"

ARG MQTT_USER=yourusername
ARG MQTT_PASS=changeme
ENV MQTT_USER=$MQTT_USER
ENV MQTT_PASS=$MQTT_PASS

WORKDIR /app

COPY main.py /app/main.py
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY requirements.txt /app/

RUN apk add mosquitto=2.0.21-r0 mosquitto-clients=2.0.21-r0 \
    openssl=3.5.2-r0 tini=0.19.0-r3 --no-cache && \
    mkdir -p /mosquitto/certs && \
    openssl genrsa -out /mosquitto/certs/ca.key 2048 && \
    openssl req -x509 -new -nodes -key /mosquitto/certs/ca.key -sha256 -days 365 \
        -subj "/C=BR/ST=SP/O=DemoCA/CN=DemoCA" \
        -out /mosquitto/certs/ca.crt && \
    openssl genrsa -out /mosquitto/certs/mosquitto.key 2048 && \
    openssl req -new -key /mosquitto/certs/mosquitto.key \
        -subj "/C=BR/ST=SP/O=DemoServer/CN=localhost" \
        -out /mosquitto/certs/mosquitto.csr && \
    openssl x509 -req -in /mosquitto/certs/mosquitto.csr -CA /mosquitto/certs/ca.crt \
        -CAkey /mosquitto/certs/ca.key -CAcreateserial \
        -out /mosquitto/certs/mosquitto.crt -days 365 -sha256 && \
    pip install --no-cache-dir --root-user-action=ignore \
    --break-system-package -r requirements.txt && \
    mkdir -p /mosquitto/config && \
    mosquitto_passwd -b -c /mosquitto/config/passwd $MQTT_USER $MQTT_PASS && \
    chown -R mosquitto:mosquitto /mosquitto && \
    chmod 0700 /mosquitto/config/passwd

EXPOSE 8883

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/sh", "-c", "mosquitto -c /etc/mosquitto/mosquitto.conf & python /app/main.py"]
