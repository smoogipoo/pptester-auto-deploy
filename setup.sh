#!/bin/bash

if [[ -z "${OSU_SERVER_REPO}" ]]; then
	OSU_SERVER_REPO=ppy/osu-server
fi

if [[ -z "${OSU_REPO}" ]]; then
	OSU_REPO=ppy/osu
fi

if [[ -z "${PP_REPO}" ]]; then
	PP_REPO=ppy/osu-performance
fi

if [[ -z "${WEB_REPO}" ]]; then
	WEB_REPO=smoogipoo/osu-web
fi

if [[ -z "${ES_REPO}" ]]; then
	ES_REPO=ppy/osu-elastic-indexer
fi

if [[ -z "${OSU_SERVER_BRANCH}" ]]; then
	OSU_SERVER_BRANCH=master
fi

if [[ -z "${OSU_BRANCH}" ]]; then
	OSU_BRANCH=master
fi

if [[ -z "${PP_BRANCH}" ]]; then
	PP_BRANCH=master
fi

if [[ -z "${WEB_BRANCH}" ]]; then
	WEB_BRANCH=pp-tester
fi

if [[ -z "${ES_BRANCH}" ]]; then
	ES_BRANCH=master
fi

echo "Using:
$OSU_SERVER_REPO -> $OSU_SERVER_BRANCH
$OSU_REPO -> $OSU_BRANCH
$PP_REPO -> $PP_BRANCH
$WEB_REPO -> $WEB_BRANCH
$ES_REPO -> $ES_BRANCH
"

read -p "Press enter to continue"

DATA_DIR=~/data
DIR=$(pwd)

PORT_FILE=$DATA_DIR/port.dat
NGINX_TEMPLATE=$DATA_DIR/nginx.tpl

# osu-web
echo "Cloning $WEB_REPO into $(pwd)..."

git clone https://github.com/$WEB_REPO .
git checkout -f origin/$WEB_BRANCH

# osu-performance
mkdir -p $DIR/osu-performance
cd $DIR/osu-performance

echo "Cloning $PP_REPO into $(pwd)..."

git clone --recurse-submodules https://github.com/$PP_REPO .
git checkout -f origin/$PP_BRANCH
git submodule update --init --recursive

# osu-server
mkdir -p $DIR/osu-server
cd $DIR/osu-server

echo "Cloning $OSU_SERVER_REPO into $(pwd)..."

# Note: No submodule recursion due to custom osu! repo
git clone https://github.com/$OSU_SERVER_REPO .
git checkout -f origin/$OSU_SERVER_BRANCH

# osu
mkdir -p $DIR/osu-server/osu
cd $DIR/osu-server/osu

echo "Cloning $OSU_REPO into $(pwd)..."

git clone --recurse-submodules https://github.com/$OSU_REPO .
git checkout -f origin/$OSU_BRANCH

# es
mkdir -p $DIR/osu-elastic-indexer
cd $DIR/osu-elastic-indexer

echo "Cloning $ES_REPO into $(pwd)..."

git clone --recurse-submodules https://github.com/$ES_REPO .
git checkout -f origin/$ES_BRANCH

# SQL + Beatmap files
echo "Copying data..."

rm -rf $DIR/beatmaps
rm -rf $DIR/sql

cp -r $DATA_DIR/sql $DIR
cp -r $DATA_DIR/beatmaps $DIR

# Setup
echo "Pre-run setup..."
cd $DIR

# Port
CURR_PORT=$(cat $PORT_FILE)
((CURR_PORT++))
echo $CURR_PORT > $PORT_FILE

echo "Setting up on port $CURR_PORT"
export NGINX_PORT=$CURR_PORT

# Nginx
SUBDOMAIN=${PWD##*/}
SITE_FILE=/etc/nginx/sites-enabled/$SUBDOMAIN

echo "Using subdomain $SUBDOMAIN"

cp $NGINX_TEMPLATE $SITE_FILE
sed -i "s/{DOMAIN}/$SUBDOMAIN/g" $SITE_FILE
sed -i "s/{PORT}/$CURR_PORT/g" $SITE_FILE

# Docker
export UID
docker-compose up
