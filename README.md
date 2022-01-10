# prometheus_deletemetrics
Cleanup script for Prometheus's TSDB. Allows the deletion of defined metrics and then runs a TSBD cleanup.

Had an issue where our TSDB was growing like crazy. Management did not want to reduce the global "keep metrics for X days. Also, it was too complicated to reconfigure the exporters to parse out specific metrics as we consume metrics from infrastructure that we do not manage. In the script, I have decided to delete anything related to windows_service* and windows_mssql* that is older than 30 days.

The script vomits logs out into stdout. You can decide what you want to do with them. I have this scheduled as a cronjob on our prometheus master.

You will need to decide what metrics you want deleted and how far back using the array and variable that is defined in the beginning of the script

Go read some docuementation if you would like :)

https://prometheus.io/docs/prometheus/latest/querying/api/#delete-series
https://prometheus.io/docs/prometheus/latest/querying/api/#clean-tombstones
