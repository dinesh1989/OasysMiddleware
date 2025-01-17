#!/bin/bash
# chkconfig: 2345 95 20
# description: Deamon Service to Start up stopped services at server startup
# processname: wso2asService
# --------------------------------------------------------------
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------
# This service script will be executed to start the servers.
# --------------------------------------------------------------
#

USER="VmAdmin"           #eg: ubuntu
PRODUCT_CODE="APIM"                               #eg: CEP
CARBON_HOME="/home/VmAdmin/wso2am-2.1.0/"               #eg: /mnt/10.0.0.1/wso2esb-4.9.0
LOCK_FILE="${CARBON_HOME}/wso2carbon.lck"
PID_FILE="${CARBON_HOME}/wso2carbon.pid"
CMD="${CARBON_HOME}/bin/wso2server.sh"  #eg: ${CARBON_HOME}/bin/wso2server.sh
JAVA_HOME="/home/VmAdmin/jdk1.7.0_60"          #eg: /usr/java/default

export JAVA_HOME=$JAVA_HOME

# Status the service
status() {
 if [ -f $PID_FILE ]
     then
  PID=`cat $PID_FILE`
  ps -fp $PID > /dev/null 2>&1
  PIDVAL=$?
     else
  PIDVAL=3
 fi

 if [ $PIDVAL -eq 0 ]
     then
  echo "WSO2 $PRODUCT_CODE server is running ..."
     else
  echo "WSO2 $PRODUCT_CODE server is stopped."
 fi
 return $PIDVAL
}

# Start the service
start() {
 if [ -f $PID_FILE ]
     then
  PID=`cat $PID_FILE`
  ps -fp $PID > /dev/null 2>&1
  PIDVAL=$?
     else
  PIDVAL=3
 fi

 if [ $PIDVAL -eq 0 ]
     then
        echo "WSO2 $PRODUCT_CODE server is running ..."
     else
        echo -n "Starting WSO2 $PRODUCT_CODE server: "
        touch $LOCK_FILE
        su - $USER -c "$CMD start > /dev/null 2>&1 &"
        sleep 5
        if [ -f $PID_FILE ]
     then
   PID=`cat $PID_FILE`
   ps -fp $PID > /dev/null 2>&1
   PIDVAL=$?
   if [ $PIDVAL -eq 0 ]
       then
    echo "success"
       else
    echo "failure"
   fi
     else
   echo "failure"
   PIDVAL=2
        fi
 fi
 echo
 return $PIDVAL
}

# Restart the service
restart() {
 echo -n "Restarting WSO2 $PRODUCT_CODE server: "
 touch $LOCK_FILE
 su - $USER -c "$CMD restart > /dev/null 2>&1 &"
 sleep 15
 if [ -f $PID_FILE ]
     then
  PID=`cat $PID_FILE`
  ps -fp $PID > /dev/null 2>&1
  PIDVAL=$?
  if [ $PIDVAL -eq 0 ]
      then
   echo "success"
      else
   echo "failure"
  fi
     else
  echo "failure"
  PIDVAL=2
 fi
 echo
 return $PIDVAL
}

# Stop the service
stop() {
 if [ -f $PID_FILE ]
     then
  PID=`cat $PID_FILE`
  ps -fp $PID > /dev/null 2>&1
  PIDVAL=$?
  if [ $PIDVAL -eq 0 ]
      then
   echo -n "Stopping WSO2 $PRODUCT_CODE server: "
   su - $USER -c "$CMD stop > /dev/null 2>&1 &"
   rm -f $LOCK_FILE
   sleep 10
   PID=`cat $PID_FILE`
   ps -fp $PID > /dev/null 2>&1
   PIDVAL=$?
   if [ $PIDVAL -eq 0 ]
       then
    echo "failure"
    PIDVAL=2
       else
    echo "success"
    PIDVAL=0
   fi
      else
         echo "WSO2 $PRODUCT_CODE server is not running."
         PIDVAL=0
  fi
     else
        echo "WSO2 $PRODUCT_CODE server is not running."
        PIDVAL=0
 fi
 echo
 return $PIDVAL
}

### main logic ###
case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
status)
    status
    ;;
restart|reload|condrestart)
    restart
    ;;
*)
   echo $"Usage: $0 {start|stop|restart|reload|status}"
   exit 1
esac
exit $?
