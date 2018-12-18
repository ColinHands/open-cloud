#!/usr/bin/env bash

INPUT=$2
echo "输入的路径 $INPUT"
FILE_PATH=`readlink -f $INPUT`
echo "输入的服务路径 $FILE_PATH"
SERVICE=${INPUT##*/}
echo "输入的服务文件名 $SERVICE"
SERVICE_NAME=${SERVICE%.*}
DEPLOY_DIR=`pwd`
if [ "$1" = "" ];
then
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
    exit 1
fi

if [ "$SERVICE" = "" ];
then
    echo -e "\033[0;31m 未输入应用名 \033[0m"
    exit 1
fi

LOGS_DIR=$DEPLOY_DIR/logs/$SERVICE_NAME
if [ ! -d $LOGS_DIR ]; then
        mkdir -p $LOGS_DIR
fi
LOG_PATH=$LOGS_DIR/stdout.out
pid=0
start()
{
	checkpid
	if [ ! -n "$pid" ]; then
    JAVA_CMD="nohup java -jar  $FILE_PATH > $LOG_PATH 2>&1 &"
    su -c "$JAVA_CMD"
    echo "---------------------------------"
    echo "启动完成，按CTRL+C退出日志界面即可>>>>>"
    echo "---------------------------------"
    sleep 2s
    tail -f $LOG_PATH
  else
      echo "$SERVICE_NAME is runing PID: $pid"
  fi
}

checkpid(){
    pid=`ps -ef |grep $FILE_PATH |grep -v grep |awk '{print $2}'`
}

stop()
{
	checkpid
    if [ ! -n "$pid" ]; then
     echo "$SERVICE_NAME not runing"
    else
      echo "$SERVICE_NAME stop..."
      kill -9 $pid
    fi
}

restart()
{
	stop
	sleep 2
	start
}

status()
{
   checkpid
   if [ ! -n "$pid" ]; then
     echo "$SERVICE_NAME not runing"
   else
     echo "$SERVICE_NAME runing PID: $pid"
   fi
}

case $1 in
          start) start;;
          stop)  stop;;
          restart)  restart;;
          status)  status;;
              *)  echo "require start|stop|restart|status"  ;;
esac
