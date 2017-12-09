#!/bin/bash

source "private_settings.sh"

cf unbind-service $APPNAME $SERVICE_INSTANCE_NAME
cf delete-service $SERVICE_INSTANCE_NAME -f 
