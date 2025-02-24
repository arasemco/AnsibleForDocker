alias ca-home='cd /home/asemo/Projects/AnsibleForDocker'
alias ca-reset='
    docker compose down &&
    docker compose up -d &&
    bash update_hosts.sh &&
    docker compose exec -it controller su - ansible
'

alias ca-shell='
    cd /home/asemo/Projects/AnsibleForDocker &&
    bash update_hosts.sh 1>/dev/null &&
    docker compose start &&
    docker compose exec -it controller su - ansible
'

alias ca-build='
    docker compose down &&
    docker compose up -d --build &&
    bash update_hosts.sh &&
    docker compose exec -it controller su - ansible
'
