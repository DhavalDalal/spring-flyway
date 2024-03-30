#!/usr/bin/env bash

USERS=("Brahma Supreme Creator" "Vishnu S. Maintainer" "Mahesh Destroyer")

for NAME in "${USERS[@]}"; do
    echo "Creating User => $NAME"
    # shellcheck disable=SC2116
    JSON=$(echo "{ \"name\" : \"$NAME\", \"email\" : \"${NAME:0:1}@tsys.com\" }")
    echo "Created JSON payload => ${JSON}"
    curl -X POST -H 'Content-Type: application/json' -d "${JSON}" http://localhost:8080/users
done

echo "verifying added users ${USERS}...in database"

./01_get_all_users.sh