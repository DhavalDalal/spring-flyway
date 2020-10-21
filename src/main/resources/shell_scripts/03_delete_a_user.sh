#!/usr/bin/env bash

echo "Deleting User $0..."
curl -X DELETE http://localhost:8080/users/$0
