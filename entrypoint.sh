#!/bin/bash
set -eu

## DATABASE
DB_ADAPTER=${DB_ADAPTER:-}
DB_ENCODING=${DB_ENCODING:-}
DB_CHARSET=${DB_CHARSET:-}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}
DB_POOL=${DB_POOL:-5}

## MAIL DELIVERY
SMTP_METHOD=${SMTP_METHOD:-smtp}
SMTP_DOMAIN=${SMTP_DOMAIN:-www.gmail.com}
SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
SMTP_PORT=${SMTP_PORT:-587}
SMTP_USER=${SMTP_USER:-}
SMTP_PASS=${SMTP_PASS:-}
SMTP_OPENSSL_VERIFY_MODE=${SMTP_OPENSSL_VERIFY_MODE:-}
SMTP_STARTTLS=${SMTP_STARTTLS:-true}
SMTP_TLS=${SMTP_TLS:-false}
SMTP_CA_ENABLED=${SMTP_CA_ENABLED:-false}
SMTP_CA_PATH=${SMTP_CA_PATH:-$REDMICA_ROOT_PATH/certs}
SMTP_CA_FILE=${SMTP_CA_FILE:-$REDMICA_ROOT_PATH/certs/ca.crt}
SMTP_ENABLED=${SMTP_ENABLED:-true}
SMTP_AUTHENTICATION=${SMTP_AUTHENTICATION:-:login}
SMTP_ENABLED=${SMTP_ENABLED:-false}

init_config() {
  cp /assets/redmica/config/database.yml.org $REDMICA_ROOT_PATH/config/database.yml
  cp /assets/redmica/config/configuration.yml.org $REDMICA_ROOT_PATH/config/configuration.yml
}

setup_configuration() {
  local fpath=$REDMICA_ROOT_PATH/config/configuration.yml

  sed -ri "s/[{]{2} ?SMTP_METHOD ?[}]{2}/$SMTP_METHOD/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_STARTTLS ?[}]{2}/$SMTP_STARTTLS/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_HOST ?[}]{2}/$SMTP_HOST/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_PORT ?[}]{2}/$SMTP_PORT/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_DOMAIN ?[}]{2}/$SMTP_DOMAIN/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_AUTHENTICATION ?[}]{2}/$SMTP_AUTHENTICATION/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_USER ?[}]{2}/$SMTP_USER/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_PASS ?[}]{2}/$SMTP_PASS/g" $fpath
  sed -ri "s/[{]{2} ?SMTP_OPENSSL_VERIFY_MODE ?[}]{2}/$SMTP_OPENSSL_VERIFY_MODE/g" $fpath
  sed -ri "s%[{]{2} ?SMTP_CA_PATH ?[}]{2}%$SMTP_CA_PATH%g" $fpath
  sed -ri "s%[{]{2} ?SMTP_CA_FILE ?[}]{2}%$SMTP_CA_FILE%g" $fpath
}

setup_database() {
  local fpath=$REDMICA_ROOT_PATH/config/database.yml

  sed -ri "s/[{]{2} ?DB_ADAPTER ?[}]{2}/$DB_ADAPTER/g" $fpath
  sed -ri "s/[{]{2} ?DB_ENCODING ?[}]{2}/$DB_ENCODING/g" $fpath
  sed -ri "s/[{]{2} ?DB_CHARSET ?[}]{2}/$DB_CHARSET/g" $fpath
  sed -ri "s/[{]{2} ?DB_HOST ?[}]{2}/$DB_HOST/g" $fpath
  sed -ri "s/[{]{2} ?DB_PORT ?[}]{2}/$DB_PORT/g" $fpath
  sed -ri "s/[{]{2} ?DB_NAME ?[}]{2}/$DB_NAME/g" $fpath
  sed -ri "s/[{]{2} ?DB_USER ?[}]{2}/$DB_USER/g" $fpath
  sed -ri "s/[{]{2} ?DB_PASS ?[}]{2}/$DB_PASS/g" $fpath
  sed -ri "s/[{]{2} ?DB_POOL ?[}]{2}/$DB_POOL/g" $fpath
}

wait_db() {
  until mysqladmin ping -h $DB_HOST -P $DB_PORT --silent;
  do
    echo "Waiting for database connection..."
    sleep 5
  done
  echo "!! database is ready."
}

init_config
setup_database
setup_configuration

wait_db

if [ ! -e /init_done ]; then
  sudo -HEu $REDMICA_USER bundle exec rake generate_secret_token
  RAILS_ENV=production sudo -HEu $REDMICA_USER bundle exec rake db:migrate
  touch /init_done
  echo "##############################"
  echo "#"
  echo "# initial migration done."
  echo "#"
  echo "##############################"
fi

exec "$@"

