#!/usr/bin/env python
#coding=utf8
#Filename: DM_DOCKER_URI.py
#****************************************************
# Author: zpang - zpang@dataman-inc.com
# Last modified: 2015-08-13 17:56
# Description:
#****************************************************
import sys
import os
import stat
import json
import urllib2
import logging

#Log Setting
Docker_logfile='/dev/stderr'
#Docker_logfile = '/Users/Prometheus/Downloads/test/test.log'
log_format = '%(asctime)s [%(filename)s] [%(levelname)s] %(message)s'
logging.basicConfig(filename = Docker_logfile,format = log_format,datefmt = '%Y-%m-%d %H:%M:%S')

#Download File
def Download_Conf(URL_Conf,Local_Conf):
    BaseLog = URL_Conf + ' download to ' + Local_Conf
    try:
        f = urllib2.urlopen(URL_Conf)
        with open(Local_Conf, "wb") as code:
            code.write(f.read())
	
	if os.path.splitext(Local_Conf)[1] == ".sh" or os.path.splitext(Local_Conf)[1] == ".py" :
	    st = os.stat(Local_Conf)
	    os.chmod(Local_Conf, 0755)

        print(BaseLog + ' is ok')
        logging.info(BaseLog + ' is ok')


        return 1

    except urllib2.HTTPError,e:
        print(BaseLog + ' is fail')
        #Read operation only once
        #print(e.fp.read())
        logging.error(BaseLog + ' is fail')
        logging.error(e.fp.read())
	exit(1)

#read url conf
def READ_CONF():
    DM_READ_URI = os.getenv('DM_READ_URI')
#    DM_READ_URI = "{'http://get.dataman-inc.com/repos/ubuntu/keya':'/data/test/key.py'}"
    #DM_READ_URI = {'':''}

    if DM_READ_URI:
        all = 0
        success = 0
        tmp = DM_READ_URI.replace("'", "\"")
        DM_URI_DICT = json.loads(tmp)
        for (key,value) in DM_URI_DICT.items():
            all += 1
            if key:
                if value:
		    dir=os.path.dirname(value)
		    isExists=os.path.exists(dir)
		    if not isExists:
        		os.makedirs(dir)
                    if Download_Conf(key,value):
                        success += 1
                else:
                    errlog = 'Local_Conf is empty, please check！'
                    print(errlog)
                    logging.error(errlog)
		    exit(1)

            else:
                errlog = 'URL is empty, please check！'
                print(errlog)
                logging.error(errlog)
		exit(1)
        if all == success:
            return 1
    else:
        errlog = 'Config File is not Change.'
        print(errlog)
        logging.info(errlog)

if "__main__" == __name__:
    print(READ_CONF())
    if READ_CONF():
        Service = ''
        if sys.argv[1:]:
            for i in sys.argv[1:]:
                Service += i + ' '
#        if Service:
#            os.system(Service)
#        else:
#            errlog = 'Service is Null and Service Not Run !'
#            print(errlog)
#            logging.error(errlog)

    else:
        errlog = 'Config File Setting is Fail! Service is Not Run !'
        #print(errlog)
        logging.error(errlog)
	exit(1)
