
#!/bin/bash
####ARGS####

cd /home/ubuntu/prometheus_maintenance

echo  "Start of script: " $(date)

IFS=","

currentTime=$(date +%s)
monthAgo=$(($currentTime - 2592000))

# We can also wildcard the names like this, I have not tested these yet. As these are passed via URL you might need to esacpe some of the characters.
# {__name__=~"windows_mssql.*"} {__name__=~"windows_service.*"} {__name__=~"wmi_mssql.*"} {__name__=~"wmi_service.*"}

# Just add here the stuff you want deleted you can even add the lables as if you were querying the backend directly. Pretty easy
seriesDelete=("wmi_service_state{}","wmi_service_status{}","wmi_service_start_mode{}","windows_service_state{}","windows_service_status{}","windows_service_start_mode{}")

echo  " - Series Deletion"

for series in $seriesDelete;do
    # deletes time series
    output=$(curl -g -X POST -o /dev/null -s -m 7200 -w '%{time_total}s,%{http_code}\n' 'http://localhost:9090/prometheus/api/v1/admin/tsdb/delete_series?end='$monthAgo'&match[]='$series)
    time=$(echo $output | awk '{print $1}')
    code=$(echo $output | awk '{print $2}')
    if [ $code -eq 204 ] ; then
        echo  "  - Deleton of "$series" suceeded with total time of "$time
    else
        echo  "  - Deletion of "$series" DID NOT succeed with exit code:"$code" and total time of "$time
    fi
done

# TSDB cleanup, this is where the space is actually got back. This has to unpack each tombstone in the entire TSDB, remove the 
echo  " - TSDB Cleanup"
output=$(curl -g -X POST -o /dev/null -s -m 7200 -w '%{time_total}s,%{http_code}\n' 'http://localhost:9090/prometheus/api/v1/admin/tsdb/clean_tombstones')
time=$(echo $output | awk '{print $1}')
code=$(echo $output | awk '{print $2}')

# Last line in log file
if [ $code -eq 204 ] ; then
    echo  "  - Cleanup of tsdb suceeded with total time of "$time
else
    echo  "  - Cleanup of tsdb DID NOT succeed with exit code:"$code" and total time of "$time
fi

echo  "End of script: " $(date)
