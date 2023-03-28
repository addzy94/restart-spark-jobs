#!/bin/bash
export PATH=$PATH:/work/aorta-stream/yaml-data-stream/scr/runner_scripts
cd /work/aorta-stream/aorta-stream-9.1.1

if [ $1 ]; then
        RUNMODE=$1;
else
        RUNMODE='REGULAR'
fi

if [ $RUNMODE == 'PEAK']; then

nohup sh run-stream.sh \
-yaml /work/aorta-stream/yaml-data-stream/dim/DIM_STG_STRM_OBU_JET.yaml \
-connectionFile /work/aorta-stream/yaml-data-stream/CONNECTIONS.yaml \
-connectionId SapHana_INVENTORY \
-master spark://spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod02.prod.skumart.com:7077,spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod03.prod.skumart.com:7077,spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod04.prod.skumart.com:7077 \
-checkpointDuration 180000 \
-checkpointDirectory swift://gis-data-stream.adc-ssdobj-106/DIM_STG_STRM_OBU_JET \
-datacenter adc \
-networkTimeout 800s \
-dstreamMemory 1g \
-cores 2 \
-executorMemory 2g \
-initialExecutors 1 \
-minExecutors 1 \
-maxExecutors 2 \
-resilience true \
-recoverByOffset true \
-metricsSinkAdapter kafka \
> /dev/null 2>&1 &

else

nohup sh run-stream.sh \
-yaml /work/aorta-stream/yaml-data-stream/dim/DIM_STG_STRM_OBU_JET.yaml \
-connectionFile /work/aorta-stream/yaml-data-stream/CONNECTIONS.yaml \
-connectionId SapHana_INVENTORY \
-master spark://spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod02.prod.skumart.com:7077,spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod03.prod.skumart.com:7077,spark.prod.gisdatastream-spark-00b-adc.bfd-ms.adcprod04.prod.skumart.com:7077 \
-checkpointDuration 180000 \
-checkpointDirectory swift://gis-data-stream.adc-ssdobj-106/DIM_STG_STRM_OBU_JET \
-datacenter adc \
-networkTimeout 800s \
-dstreamMemory 1g \
-cores 2 \
-executorMemory 2g \
-initialExecutors 1 \
-minExecutors 1 \
-maxExecutors 2 \
-resilience true \
-recoverByOffset true \
-metricsSinkAdapter kafka \
> /dev/null 2>&1 &

fi
