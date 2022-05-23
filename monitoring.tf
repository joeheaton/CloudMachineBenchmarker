resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = <<EOT
{
  "displayName": "Cloud Machine Benchmark",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "height": 4,
        "widget": {
          "title": "Cloud Machine Benchmark - VM Instance - CPU utilization (filtered) (grouped) [SUM]",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": [
                        "metadata.user_labels.\"cmbench_id\"",
                        "metadata.system_labels.\"machine_type\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    },
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" metadata.user_labels.\"cmbench_type\"=\"compute\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s"
                    }
                  }
                }
              }
            ],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6
      }
    ]
  }}
  EOT
}