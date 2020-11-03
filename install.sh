#!/bin/bash

if [ $1 == '--help' ]; then
    echo "usage: install.sh your-domain"
    echo "./install.sh test.akhromlyuk.dev"
fi

set -eu

. ./installer/logs

main() {
    to_action "[START] installer"
    warn "Удаляю venv"
    rm -rf venv

    python3_worker
    pip_worker
    success "SUCCESS"
    to_action "[END] installer"
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

