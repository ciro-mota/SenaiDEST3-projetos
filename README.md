# Senai Desenvolvimento de Sistemas - Projetos

> [!WARNING]
> Este repo é apenas para fins educacionais, baseado nas minhas atividades no curso Técnico em Desenvolvimento de Sistemas e não deve ser utilizado para ambiente de produção.

## Objetivo

Este projeto tem como objetivo demonstrar uma comunicação MQTT "mão dupla" entre um **ESP32** simulado na plataforma [Wokwi](https://wokwi.com/) e um **broker Mosquitto** executando em um ambiente Docker em uma instância na nuvem, no exemplo a [DigitalOcean](https://m.do.co/c/59a80b08da11).

Esse fluxo simula o funcionamento de um comando `ping` tradicional permitindo testar comunicação bidirecional via `MQTT` em ambiente seguro e *containerizado*.

O comportamento é:

1. O ESP32 envia uma mensagem `"ping"` para o broker.
2. O broker recebe a mensagem e responde com `"pong"`.
3. O ESP32 reconhece a resposta e aciona um display `LCD I²C` (simulado via Wokwi) mostrando uma mensagem de confirmação.

## Estrutura do Projeto

```
mqtt-pingpong/
├─ docker-compose.yml # Orquestra os containers (broker Mosquitto + app Python)
├─ .env # Variáveis de ambiente
├─ mosquitto/
│ ├─ mosquitto.conf # Configuração do broker Mosquitto
│ └─ passwd # Arquivo gerado com hash bcrypt do usuário MQTT
└─ app/
├─ Dockerfile # Container Python para o MQTT
├─ requirements.txt # Dependências Python
└─ main.py # Script principal que envia e recebe mensagens MQTT
```

## Pré-requisitos

- Instância na nuvem.
- Docker e Docker Compose.
- Python3 (no container `app`).
- [Wokwi](https://wokwi.com/) (simulação do ESP32 e LCD I²C).

## Configuração

### ESP32 no Wokwi:

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

- Clone o repo:

```bash
git clone https://github.com/ciro-mota/SenaiDEST3-projetos && cd "$(basename "$_" .git)
```
- Execute o arquivo `script.sh` para provisionar o ambiente.
- Salve uma cópia do código no [Wokwi](https://wokwi.com/projects/439649923166542849).
- Execute o comando abaixo para construir a imagem. Mude os argumentos de `usuário` e `senha` para os seus.

```bash
docker buildx build --build-arg MQTT_USER=ciro \
--build-arg MQTT_PASS=supersegredo \
 -t pymosquitto files
```

- Execute o comando abaixo para rodar a aplicação:

```bash
docker container run -itd -p 8883:8883 pymosquitto
```

- Modifique os parâmetros obrigatórios no projeto no Wokwi e construa-o para o funcionamento.

## Segurança

O Mosquitto utiliza o arquivo `passwd` com hash `bcrypt`, garantindo que o broker valide a senha sem expô-la diretamente.

Criptografada via TLS protegendo usuário, senha e mensagens MQTT.

## Próximos Passos

- [x] A senha do usuário MQTT é armazenada em texto plano no arquivo `.env` e precisará ser utilizado outro método para evitar exposição direta.

- [ ] Implementar mais tópicos e lógica de comunicação bidirecional no ESP32.

- [x] Adicionar autenticação TLS para o broker Mosquitto.

- [x] Automatizar todo o setup com um shell script (geração do passwd, build do app e docker-compose up).
