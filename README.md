# SenaiDEST3-projetos

> [!WARNING]
> Este repo é para apenas fins educacionais baseado nas minhas atividades no curso Técnico em Desenvolvimento de Sistemas e não deve ser utilizado para ambiente de produção.

## Objetivo

Este projeto tem como objetivo demonstrar uma comunicação MQTT "mão dupla" entre um **ESP32** simulado no [Wokwi](https://wokwi.com/) e um **broker Mosquitto** executando em um ambiente Docker em uma cloud, no exemplo a DigitalOcean.

O comportamento principal é:

1. O ESP32 envia uma mensagem `"ping"` para o broker.
2. O broker recebe a mensagem e responde com `"pong"`.
3. O ESP32 reconhece a resposta e aciona um display LCD `I²C` (simulado via Wokwi) mostrando uma mensagem de confirmação.

Esse fluxo simula o funcionamento de um comando `ping` tradicional permitindo testar comunicação bidirecional via MQTT em ambiente seguro e *containerizado*.

---

## Estrutura do Projeto

```
mqtt-pingpong/
├─ docker-compose.yml # Orquestra os containers (broker Mosquitto + app Python)
├─ .env # Variáveis de ambiente (opcional, apenas MQTT_USER)
├─ mosquitto/
│ ├─ mosquitto.conf # Configuração do broker Mosquitto
│ └─ passwd # Arquivo gerado com hash bcrypt do usuário MQTT
└─ app/
├─ Dockerfile # Container Python para testes MQTT
├─ requirements.txt # Dependências Python
└─ main.py # Script principal que envia e recebe mensagens MQTT
```

---

## Pré-requisitos

- Docker e Docker Compose instalados
- Python3 no container `app`
- Wokwi (simulação do ESP32 e LCD I²C)

---

## Setup

### Configuração do ESP32 no Wokwi:

    SDA → GPIO 21
    SCL → GPIO 22
    VCC → 5V
    GND → GND

### Personalização do LCD no Wokwi

Você pode alterar a cor de fundo e do texto do LCD diretamente no `diagram.json`:

```
"attrs": { "pins": "i2c", "background": "blue", "color": "white" }
```

### Execução

- Execute o arquivo `script.sh` para provisionar o ambiente.
- Salve uma cópia do código no [Wokwi](https://wokwi.com/projects/439649923166542849), modifique os parâmetros obrigatórios e construa o projeto.

## Segurança

O Mosquitto utiliza o arquivo passwd com hash bcrypt, garantindo que o broker valide a senha sem expô-la diretamente.

## Próximos Passos

[ ] A senha do usuário MQTT é armazenada em texto plano no .env e precisará ser utilizado outro método.

[ ] Adicionar autenticação TLS para o broker Mosquitto.

[ ] Automatizar todo o setup com um shell script (geração do passwd, build do app e docker-compose up).

[ ] Implementar mais tópicos e lógica de comunicação bidirecional no ESP32.