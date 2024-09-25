#!/bin/bash

CLICKHOUSE_SERVICES_ARRAY=($(echo $CLICKHOUSE_SERVICES | tr ',' '\n' | sed '/^$/d'))
BACKUP_DATE=$(date +%Y-%m-%d-%H-%M-%S);
BACKUP_NAME="full-${BACKUP_DATE}";
if [[ "" != "$BACKUP_PASSWORD" ]]; then
BACKUP_PASSWORD="--password=$BACKUP_PASSWORD";
fi;
for SERVER in $CLICKHOUSE_SERVICES_ARRAY; do
echo "create $BACKUP_NAME on $SERVER";
clickhouse client --echo -mn -q "INSERT INTO system.backup_actions(command) VALUES('create ${SERVER}-${BACKUP_NAME}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
done;
for SERVER in $CLICKHOUSE_SERVICES_ARRAY; do
while [[ "in progress" == $(clickhouse client -mn -q "SELECT status FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
    echo "still in progress $BACKUP_NAME on $SERVER";
    sleep 1;
done;
if [[ "success" != $(clickhouse client -mn -q "SELECT status FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
    echo "error create $BACKUP_NAME on $SERVER";
    clickhouse client -mn --echo -q "SELECT status,error FROM system.backup_actions WHERE command='create ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
    exit 1;
fi;
done;
for SERVER in $CLICKHOUSE_SERVICES_ARRAY; do
echo "upload $BACKUP_NAME on $SERVER";
clickhouse client --echo -mn -q "INSERT INTO system.backup_actions(command) VALUES('upload ${SERVER}-${BACKUP_NAME}')" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
done;
for SERVER in $CLICKHOUSE_SERVICES_ARRAY; do
while [[ "in progress" == $(clickhouse client -mn -q "SELECT status FROM system.backup_actions WHERE command='upload ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; do
    echo "upload still in progress $BACKUP_NAME on $SERVER";
    sleep 5;
done;
if [[ "success" != $(clickhouse client -mn -q "SELECT status FROM system.backup_actions WHERE command='upload ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD) ]]; then
    echo "error $BACKUP_NAME on $SERVER";
    clickhouse client -mn --echo -q "SELECT status,error FROM system.backup_actions WHERE command='upload ${SERVER}-${BACKUP_NAME}'" --host="$SERVER" --port="$CLICKHOUSE_PORT" --user="$BACKUP_USER" $BACKUP_PASSWORD;
    exit 1;
fi;
done;
echo "BACKUP CREATED"
