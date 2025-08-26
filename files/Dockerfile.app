FROM python:alpine3.22

LABEL org.opencontainers.image.title="app"
LABEL org.opencontainers.image.description="Communicate with the ESP32 project running under Wowki."
LABEL org.opencontainers.image.authors="Ciro Mota <github.com/ciro-mota> (@ciro-mota)"
LABEL org.opencontainers.image.url="https://github.com/ciro-mota/SenaiDEST3-projetos"
LABEL org.opencontainers.image.documentation="https://github.com/ciro-mota/SenaiDEST3-projetos#README"
LABEL org.opencontainers.image.source="https://github.com/ciro-mota/SenaiDEST3-projetos"

ARG MQTT_USER=demo
ARG MQTT_PASS=changeme
ENV MQTT_USER=$MQTT_USER
ENV MQTT_PASS=$MQTT_PASS

WORKDIR /app

COPY requirements.txt .
COPY main.py .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "main.py"]
