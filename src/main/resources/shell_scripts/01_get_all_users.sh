#!/usr/bin/env bash

echo "Getting All Users..."
curl http://localhost:8080/users | jq