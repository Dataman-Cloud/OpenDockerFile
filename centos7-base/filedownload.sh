#!/bin/sh
# 根据环境变量组合下载配置文件
# Author : jyliu
# Date : 2016.6.13

if [ "x$CONFIG_SERVER" != "x" ];then
    filelist_url=$CONFIG_SERVER/config

    if [ "$MATCH_HOSTNAME" = "true" ];then
        filelist_url=$filelist_url/$(hostname)
    fi

    if [ "x$SERVICE" != "x" ];then
        filelist_url=$filelist_url/$SERVICE
    fi

    if [ "x$SERVICEPORT" != "x" ];then
        filelist_url=$filelist_url/$SERVICEPORT
    fi

    export DM_READ_URI=`curl $filelist_url/filelist.json`
fi

if [ "x$DM_READ_URI" != "x" ];then
        /DM_DOCKER_URI.py
fi
