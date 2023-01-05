#!/bin/sh

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://84.201.136.153:8083/connectors/ -d @register-postgres.json