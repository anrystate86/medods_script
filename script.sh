#!/bin/bash
if [ -n "$1" ]
then
SERVER_NAME=$1
else
SERVER_NAME="RANDOM_SERVER"
fi

# 1
wget https://raw.githubusercontent.com/GreatMedivack/files/master/list.out
if ! [ $? -eq 0 ]
then
  echo "Could not get list.out"
  exit 1
fi

if [ ! -s list.out ]
then
  echo "list.out is empty"
  exit 1
fi

echo  $SERVER_NAME"_"$(date +%d_%m_%Y)
SERVER_DATE=$SERVER_NAME"_"$(date +%d_%m_%Y)
FAILED_FILENAME=$SERVER_DATE"_failed.out"
RUNNING_FILENAME=$SERVER_DATE"_running.out"
SERVER_REPORT=$SERVER_DATE"_report.out"
ARCHIVE_FILENAME=$SERVER_DATE".tar.gz"

# 2
awk '/Error|CrashLoopBackOff/ {print $1}' list.out | sed -e 's/\-[[:alnum:]]\{10\}\-[[:alnum:]]\{5\}$//g' > $FAILED_FILENAME
awk '/Running/ {print $1}' list.out | sed -e 's/\-[[:alnum:]]\{10\}\-[[:alnum:]]\{5\}$//g' > $RUNNING_FILENAME

# 3
echo "- Количество работающих сервисов: "$(cat $RUNNING_FILENAME | wc -l) > $SERVER_REPORT
echo "- Количество сервисов с ошибками: "$(cat $FAILED_FILENAME | wc -l) >> $SERVER_REPORT
echo "- Имя системного пользователя: "$(whoami) >> $SERVER_REPORT
echo "- Дата: "$(date +%d/%m/%Y) >> $SERVER_REPORT
chmod 444 $SERVER_REPORT

# 4
if ! [ -d archives ]
then
  mkdir archives
fi

if ! [ -f archives/$ARCHIVE_FILENAME ]
then
tar -czvf archives/$ARCHIVE_FILENAME $SERVER_DATE*
fi

# 5
shopt -s extglob
rm -rf !(script.sh|archives)

# 6
tar -tvzf archives/$ARCHIVE_FILENAME > /dev/null
if [ $? -eq 0 ]
then
  echo "Work is done!"
  exit 0
else
  echo "Archive check failed"
  exit 1
fi
