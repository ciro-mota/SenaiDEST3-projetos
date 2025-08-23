import os
import time
import logging
import ssl
import paho.mqtt.client as mqtt

MQTT_HOST = os.getenv("MQTT_HOST", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", 8883))
MQTT_USER = os.getenv("MQTT_USER", "")
MQTT_PASS = os.getenv("MQTT_PASS", "")
TOPIC_PING = os.getenv("TOPIC_PING", "envia")
TOPIC_PONG = os.getenv("TOPIC_PONG", "recebe")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()

logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s: %(message)s")
log = logging.getLogger("pingpong")

client = mqtt.Client(
    client_id="do-pingpong-app",
    protocol=mqtt.MQTTv311,
    callback_api_version=mqtt.CallbackAPIVersion.VERSION2
)

client.tls_set(
    ca_certs="/mosquitto/certs/ca.crt",
    certfile=None,
    keyfile=None,
    cert_reqs=ssl.CERT_REQUIRED,
    tls_version=ssl.PROTOCOL_TLSv1_2
)
client.tls_insecure_set(False)

if MQTT_USER:
    client.username_pw_set(MQTT_USER, MQTT_PASS)

client.connect(MQTT_HOST, MQTT_PORT, 60)

def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == mqtt.CONNACK_ACCEPTED:
        log.info("Conectado ao broker %s:%s", MQTT_HOST, MQTT_PORT)
        client.subscribe(TOPIC_PING, qos=1)
        log.info("Assinado em '%s'", TOPIC_PING)
    else:
        log.error("Falha na conexão (rc=%s)", reason_code)

def on_message(client, topic, payload, qos, properties):
    payload_str = payload.decode("utf-8", errors="replace")
    log.info("Mensagem recebida em [%s]: %s", topic, payload_str)
    if payload_str.strip().lower() == "ping":
        client.publish(TOPIC_PONG, "pong", qos=1, retain=False)
        log.info("Enviado 'pong' em '%s'", TOPIC_PONG)

def on_disconnect(client, reason_code, properties=None):
    log.warning("Desconectado (rc=%s). Reconectando...", reason_code)

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
