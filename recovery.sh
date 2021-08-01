#!/bin/bash

FILENAME=/work/aorta-stream/yaml-data-stream/scr/processes.txt
LOG_FILE="/work/aorta-stream/yaml-data-stream/scr/logs/recovery.$( date +%Y-%m-%d--%H:%M:%S ).log"

touch $LOG_FILE

{

while read line; do

  echo "************************************************************************"

  HOSTNAME=$( cut -d':' -f1 <<<  $line | sed 's/ //g' )
  PROCESS_NAME=$( cut -d':' -f2 <<<  $line | sed 's/ //g' )
  MAX_DURATION=$( cut -d':' -f3 <<<  $line | sed 's/ //g' )
  RUN_TYPE=$( cut -d':' -f4 <<<  $line | sed 's/ //g' )

  echo "Checking for $PROCESS_NAME on $HOSTNAME with max duration of $MAX_DURATION seconds."

  if [ $HOSTNAME == `hostname` ] # Making sure check is done on designated host
    then
      echo "$HOSTNAME is the right host for $PROCESS_NAME."
      OUTPUT=$(pgrep -cf ".*$PROCESS_NAME.*")
      if [ $OUTPUT -eq 0 ]
        then
          echo "Process is not Running!"
          sudo su - spark /work/aorta-stream/yaml-data-stream/scr/runner_scripts/"$PROCESS_NAME".sh "$RUN_TYPE"
          echo "Process is starting now."
        else
          DURATION=$( ps -p `pgrep -f ".*$PROCESS_NAME.*" -n` -o etime --no-headers | sed 's/ //g' )
          SECONDS_DURATION=0
          if [[ $DURATION =~ "-" ]]
            then
              DAYS=$( sed s'/-.*//' <<< $DURATION )
              (( SECONDS_DURATION += 10#$DAYS * 86400 ))
          fi
          TIME=$( sed s'/.*-//' <<< $DURATION )
          HOURS=$( rev <<< $TIME | cut -d ':' -f3 | rev )
          MINUTES=$( rev <<< $TIME | cut -d ':' -f2 | rev )
          SECONDSS=$( rev <<< $TIME | cut -d ':' -f1 | rev )
          ((SECONDS_DURATION += (10#$HOURS * 3600) + (10#$MINUTES * 60) + (10#$SECONDSS) ))
          echo "Duration is $DURATION."
          echo "Process $PROCESS_NAME has been running for $SECONDS_DURATION seconds."
          if [ $SECONDS_DURATION -gt $MAX_DURATION ]
            then
              echo "Process Running longer than max duration. Will be restarted."
              KILL_PROCESS_ID=$( pgrep -f ".*$PROCESS_NAME.*" -n )
              sudo kill -KILL $KILL_PROCESS_ID
              sleep 5s
              sudo su - spark /work/aorta-stream/yaml-data-stream/scr/runner_scripts/"$PROCESS_NAME".sh "$RUN_TYPE"
              echo "Process $PROCESS_NAME has been restarted."
            else
              echo "Process $PROCESS_NAME is within time-limit"
          fi
      fi
    else
      echo "Wrong process $PROCESS_NAME for the host! Skipping on $HOSTNAME"
  fi

done < $FILENAME

} >> $LOG_FILE

find /work/aorta-stream/yaml-data-stream/scr/logs/ -type f -name '*.log' -mtime +2 -exec rm {} \;
find /work/aorta-stream/aorta-stream-9.1.1/logs/ -type f -name '*.log*' -mtime +3 -exec rm {} \;
