40 CPUs
12 otels
30 CH


75 CPUs
60 CH
16 otels



350K spans/s in 5 shards 16 CPUs each
1VM with 16CPUs will ingest 70K spans/s => 70K spans/s * 0.2Kb => 14MB/s




500K spans/s in 10 shards with 10 VMs of 16CPUs each
120 CPUs used out of 160 CPUs
91 CPUs used by CH
22 CPUs used by otels

Stiky connection to pods causes ingestion to not increase with increasing receiver nodes


THINGS TO DO
1. GLOBAL INNER JOIN
2. TTL
3. Partition for traces/logs (hour or day?)
4. How many otel-collectors are needed? Auto scale based on req
5. Tables are not auto created on adding shard as table creation logic is in otel-collector
6. CPU, memory and disk I/O profile
7. Query perf

https://github.com/jaegertracing/jaeger/issues/1410


## distributed_metrics.json

SELECT  toStartOfInterval(timestamp, INTERVAL 5 MINUTE) as ts, toFloat64(count()/300) FROM signoz_traces.distributed_signoz_index_v2 where timestamp>now64() - INTERVAL 240 MINUTE GROUP BY ts ORDER BY ts ASC;

SELECT  ts, runningDifference(value)/runningDifference(ts) as value FROM(SELECT  toStartOfInterval(toDateTime(intDiv(timestamp_ms, 1000)), INTERVAL 60 SECOND) as ts, sum(value) as value FROM signoz_metrics.distributed_samples_v2 GLOBAL INNER JOIN (SELECT  fingerprint FROM signoz_metrics.distributed_time_series_v2 WHERE metric_name = 'otelcol_receiver_accepted_spans') as filtered_time_series USING fingerprint WHERE metric_name = 'otelcol_receiver_accepted_spans' AND timestamp_ms > toUnixTimestamp(now() - INTERVAL 30 MINUTE)*1000 GROUP BY ts ORDER BY  ts) ORDER BY ts OFFSET 1 ROW FETCH FIRST 29 ROWS ONLY;


SELECT  toStartOfInterval(fromUnixTimestamp(toInt32(timestamp_ms/1000)), INTERVAL 1 MINUTE) as ts, toFloat64(count()/60) FROM signoz_metrics.distributed_samples_v2 where timestamp_ms>toUnixTimestamp(now() - INTERVAL 30 MINUTE)*1000 GROUP BY ts ORDER BY ts ASC;


SELECT
    ts,
    sum(runningDifference(value) / runningDifference(ts)) AS value,
    instance
FROM
(
    SELECT
        toStartOfInterval(toDateTime(intDiv(timestamp_ms, 1000)), toIntervalMinute(1)) AS ts,
        max(value) AS value,
        labels_values[indexOf(labels_keys, 'instance')] AS instance
    FROM signoz_metrics.distributed_samples_v2
    WHERE (metric_name = 'node_cpu_seconds_total') AND (fingerprint GLOBAL IN (
        SELECT fingerprint
        FROM signoz_metrics.distributed_time_series_v2
        WHERE (metric_name = 'node_cpu_seconds_total') AND ((labels['instance']) LIKE 'host%')
    )) AND (timestamp_ms > toUnixTimestamp(now() - INTERVAL 60 MINTUTE)*1000)
    GROUP BY
        instance,
        ts
    ORDER BY
        instance ASC,
        ts ASC
)
GROUP BY
    instance,
    ts
ORDER BY
    instance ASC,
    ts ASC