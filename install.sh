#!/bin/bash

if [ "${1:-""}" = '--help' -o "${1:-""}" = "" ]; then
    echo "usage: install.sh your-domain"
    echo -e "1: введите желаемый адрес сайта\n2: введите порт\n3: Использовать ssl 'true' (опционально, по умолчанию true)"
    echo "./install.sh test.akhromlyuk.dev 9001"
    exit 0
fi

set -eu

DOMAIN="${1:-"default_socket.akhromlyuk.dev"}"
PORT="${2:-"9001"}"
SSLON="${3:-"true"}"
SERVER_IP="$(ip -4 a | grep "inet" | egrep "/24" | \
 awk -F' ' '{ print $2 }' | rev | cut -c 4- | rev)"

. ./installer/logs

. ./installer/utils

main() {
    to_action "[START] installer"
    warn "Удаляю venv"
    rm -rf venv

    python3_worker
    pip_worker
    install_service
    install_nginx
    success "SUCCESS"
    to_action "[END] installer"
    _end "http://$DOMAIN" "$SERVER_IP:$PORT"
    return 0
}


pip_worker() {
    local pip="./venv/bin/pip"

    $pip install --upgrade pip

    if [ -f requirements.txt ]; then
        warn "Устанавливаю из requirements.txt"
        $pip install -r requirements.txt
    fi

    $pip install gunicorn
    to_action "pip_worker отработал"
    return 0
}

python3_worker() {
    local python="./venv/bin/python3"
    to_action "Создаю venv"
    python3 -m venv venv
    success "venv создан успешно"
    return 0
}

main "$@"

exit 0