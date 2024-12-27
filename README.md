# Observability Stack

This project sets up an observability stack to collect, process, and visualize metrics, traces, and logs using tools like **OpenTelemetry Collector**, **Prometheus**, **Tempo**, **Loki**, **Fluent Bit**, and **Grafana**.

---

## Stack Architecture

1. **Metrics and Traces**:
   - **Collector**: Receives metrics and traces.
     - **Metrics**: Sent to **Prometheus**.
     - **Traces**: Sent to **Tempo**.

2. **Logs**:
   - **Fluent Bit**: Receives logs and forwards them to **Loki**.

3. **Visualization**:
   - **Grafana**: Integrates data from **Prometheus**, **Tempo**, and **Loki** to provide dashboards for metrics, traces, and logs.

---

## Prerequisites

- Docker and Docker Compose installed.
- Required open ports:
  - **Grafana**: 3000
  - **Prometheus**: 9090
  - **Loki**: 3100
  - **Tempo**: 3200
  - **Collector**: 4318, 4317
  - **Fluent Bit**: 4320

---

## Stack Configuration

### 1. Configuration Files
- **`docker-compose.yml`**: Defines the stack services.
- **OpenTelemetry Collector Configuration**: Configured to receive metrics and traces.
- **Fluent Bit Configuration**: Configured to receive and process logs.

# Project Structure

``` bash
.
├── docker-compose.yml       # Service configuration
├── LICENSE                  # Project license
├── README.md                # Documentation
├── load.sh                  # Script to generate logs and traces
└── resources/               # Configuration directories for each tool
    ├── fluent-bit/          # Fluent Bit configuration
    │   └── fluent-bit.conf  # Fluent Bit configuration file
    ├── grafana/             # Grafana configuration
    │   └── grafana.ini      # Grafana main configuration file
    ├── loki/                # Loki configuration
    │   └── loki-config.yml  # Loki configuration file
    ├── otel-collector/      # OpenTelemetry Collector configuration
    │   └── collector.yaml   # OpenTelemetry Collector configuration file
    ├── prometheus/          # Prometheus configuration
    │   └── prometheus.yml   # Prometheus configuration file
    └── tempo/               # Tempo configuration
        └── tempo.yml        # Tempo configuration file
```
---

## Instructions

### 1. Start the Stack

To start all containers defined in the `docker-compose.yml` file:

```bash
docker compose up -d
```

You can verify that the containers are running with:
```bash 
docker compose ps
```

### 2.  Send Logs and Traces
To generate logs and traces, use the provided script:

Grant execution permissions to the script:

```bash 
chmod +x ./load.sh
```

Run the script:
```bash 
./load.sh 6
```

### 3.  View Data in Grafana
Open Grafana in your browser: http://localhost:3000. Log in (username: admin, password: admin).
Configure the data sources: Prometheus for metrics. Tempo for traces. Loki for logs.
Explore pre-configured dashboards or create new ones to visualize the data.

![alt text](<images/Captura de pantalla 2024-12-27 a las 13.15.37.png>)

### Viewing Traces in Grafana

To analyze traces using their `traceId` in Grafana, follow these steps:

1. **Open the Traces Table**:
   - Navigate to the dashboard that displays the traces in a table format.
   - The table should include a column for `traceId` along with other relevant fields.

2. **Locate the `traceId`**:
   - Identify the specific `traceId` you want to analyze from the table.

3. **Select the `traceId`**:
   - Click on the `traceId` value. This should either:
     - Redirect you to a pre-configured Tempo dashboard, where you can view detailed trace information.
     - Open a query window within Grafana to explore the trace data.

4. **Explore the Trace Details**:
   - The detailed view will include information such as spans, duration, services involved, and any errors associated with the trace.

5. **Use the Trace Filters** (Optional):
   - Apply filters in the trace table to narrow down the results by fields such as `service`, `method`, or `error` status.

6. **Correlate Logs with Traces** (Optional):
   - If your dashboard is set up to correlate logs and traces:
     - Click on a span or trace detail to view associated logs in Loki.
     - This provides additional context for debugging and analysis.

> **Tip**: Ensure that the `traceId` in your traces matches the `traceId` in your logs to enable seamless correlation between metrics, logs, and traces.

---

By following these steps, you can effectively use Grafana to analyze and debug distributed traces in your observability stack.

![alt text](<images/Captura de pantalla 2024-12-27 a las 13.21.28.png>)

### Exploring Logs and Navigating to Traces

In the logs table, you can explore all the logs collected in your observability stack. Each log entry is enriched with a `traceId` that allows you to correlate it with its associated trace in Tempo. Follow these steps:

1. **Open the Logs Table**:
   - Navigate to the dashboard displaying the logs table.
   - The table should include fields like `timestamp`, `service`, `level`, `message`, and `traceId`.

2. **Locate the `traceId`**:
   - Identify the log entry you want to investigate.
   - Look for the `traceId` column in the table, which links the log entry to its trace.

3. **Use the `traceId` Button**:
   - Each `traceId` will have a clickable button or link.
   - Click on the button to navigate directly to Tempo, where the trace associated with the selected `traceId` will be displayed.

4. **Explore the Trace in Tempo**:
   - In Tempo, you can see detailed trace information, including:
     - All the spans involved in the trace.
     - The duration of each span.
     - The services and operations that contributed to the trace.

5. **Correlate Logs and Traces**:
   - Use this feature to understand the flow of the request captured in the trace and the related log messages for deeper debugging.

6. **Optional Filters**:
   - You can also apply filters in the logs table to narrow down results based on fields such as `level` (e.g., `error`, `warn`, `info`) or `service`.

---

### Key Benefits of Trace-Log Correlation
- Quickly navigate between logs and their associated traces for faster debugging.
- Gain a complete view of both structured logs and distributed traces in a single workflow.
- Identify performance bottlenecks or errors by analyzing logs in the context of traces.

By using the `traceId` as the link between logs and traces, you can seamlessly explore and debug your system in Grafana and Tempo.

![alt text](<images/Captura de pantalla 2024-12-27 a las 13.58.01.png>)

### Viewing Log Details and Navigating to Traces

When exploring a log entry in the logs table, you can view its detailed information, including fields like `timestamp`, `service`, `level`, `message`, and `traceId`. The `traceId` plays a crucial role in correlating the log with its associated trace. Here's how it works:

1. **Expand a Log Entry**:
   - Click on a log entry to reveal its detailed information.
   - The details will include all relevant fields, such as the `traceId`.

2. **Navigate Using the `traceId`**:
   - The `traceId` is displayed as a clickable button or link.
   - Click the button to directly navigate to Tempo, where the trace linked to this log entry is visualized.

3. **Trace Visualization in Tempo**:
   - In Tempo, you can analyze the trace associated with the log, including all related spans, services, and operations.

---

This seamless integration between logs and traces simplifies debugging and provides a comprehensive view of system activity, allowing you to correlate logs with traces efficiently using the `traceId`.

![alt text](<images/Captura de pantalla 2024-12-27 a las 14.02.34.png>)

### Split View: Navigating from Logs to Traces in Tempo

When navigating from a log entry to its associated trace in Tempo, you can utilize the split-view feature to analyze the trace in detail while keeping the context of the log. This enhances the debugging process by providing both perspectives simultaneously.

1. **Navigate to Tempo from a Log**:
   - Click the `traceId` button in the log entry to open the associated trace in Tempo.

2. **Split-View Interface**:
   - Tempo opens the trace in a split-view layout:
     - **Left Panel**: Displays the spans of the trace, including their hierarchy, duration, and services involved.
     - **Right Panel**: Shows the detailed attributes and metadata of the selected span, including associated logs and errors.

3. **Benefits of Split View**:
   - Quickly switch between spans and their details without losing the context of the entire trace.
   - Correlate the log entry with specific spans to pinpoint issues or performance bottlenecks.

---

By leveraging Tempo's split-view feature, you can perform in-depth trace analysis while maintaining the context provided by the originating log, ensuring a streamlined debugging workflow.

![alt text](<images/Captura de pantalla 2024-12-27 a las 14.05.17.png>)

---

## Final Notes

This observability stack provides an integrated approach to monitoring, logging, and tracing, allowing you to efficiently debug, analyze, and optimize your system's performance. By correlating metrics, logs, and traces in Grafana, you gain a holistic view of your infrastructure.

If you encounter any issues or have suggestions for improvements, feel free to contribute or open an issue in this repository.

---

## License

This project is licensed under the [MIT License](LICENSE).

---



