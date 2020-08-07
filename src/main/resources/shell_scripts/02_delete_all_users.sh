#!/usr/bin/env bash

echo "Deleting All Users..."
curl -X DELETE http://localhost:8080/users
echo "verifying deleted users..."
curl http://localhost:8080/users | jq