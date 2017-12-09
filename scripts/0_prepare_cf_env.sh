#!/bin/bash

source "private_settings.sh"

cf create-service $SERVICE_NAME $SERVICE_PLAN_NAME $SERVICE_INSTANCE_NAME
