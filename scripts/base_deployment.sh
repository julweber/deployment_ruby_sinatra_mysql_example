#!/bin/bash

source "private_settings.sh"

echo "list all existing apps within space $SPACE :"
cf apps

echo "list all available domains:"
cf domains

echo "deploy application $APPNAME to space $SPACE using manifest file $MANIFEST :"
cf push $APPNAME -f $MANIFEST

echo "list apps:"
cf apps

echo "get information about the running app:"
cf app "$APPNAME"

echo "access deployed app / route:"
curl "$APPNAME.$DOMAIN"
