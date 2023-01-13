#!/bin/sh

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://130.193.40.81:8083/connectors/ -d @register-postgres.json