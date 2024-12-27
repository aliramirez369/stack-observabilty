#!/bin/bash

# Termina si ocurre un error
set -e

# Dirección del OpenTelemetry Collector
COLLECTOR_URL="http://localhost:4318"

# Número de datos a generar (argumento del script)
DATA_COUNT="$1"

generate_trace_id() {
  echo "$(hexdump -n 16 -e '8/4 "%08x"' /dev/urandom | head -c 32)"
}

generate_span_id() {
  echo "$(hexdump -n 8 -e '4/4 "%08x"' /dev/urandom | head -c 16)"
}

# Función para obtener soporte de nanosegundos
supports_nanoseconds() {
  if [[ "$(date +%N 2>/dev/null)" =~ ^[0-9]+$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

USE_NANOSECONDS=$(supports_nanoseconds)

# Función para obtener el timestamp inicial en nanosegundos
generate_timestamp() {
  local seconds=$(date +%s)
  local nanoseconds="000000000" # Valor predeterminado

  if [ "$USE_NANOSECONDS" = "true" ]; then
    nanoseconds=$(date +%N)
  fi

  echo "$((seconds * 1000000000 + 10#$nanoseconds))"
}

# Intervalo entre registros (100ms en nanosegundos)
INTERVAL_NS=100000000

# Función para seleccionar un nivel de severidad aleatorio
random_severity_level() {
  local levels=("error" "warn" "info")
  echo "${levels[$RANDOM % ${#levels[@]}]}"
}

# Función para enviar una traza
send_trace() {
  local trace_id="$1"
  local span_id="$2"
  local parent_span_id="$3"
  local timestamp="$4"

  echo "Enviando traza:"
  echo "  TraceID: $trace_id"
  echo "  SpanID: $span_id"
  echo "  ParentSpanID: $parent_span_id"
  echo "  Timestamp: $timestamp"

  curl -s -X POST "$COLLECTOR_URL/v1/traces" \
    -H "Content-Type: application/json" \
    -d @- <<EOF
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "trace-service"}},
          {"key": "environment", "value": {"stringValue": "production"}}
        ]
      },
      "scopeSpans": [
        {
          "scope": {"name": "trace-scope"},
          "spans": [
            {
              "traceId": "$trace_id",
              "spanId": "$span_id",
              "parentSpanId": "$parent_span_id",
              "name": "Root Span - Trace Service",
              "kind": "SPAN_KIND_SERVER",
              "startTimeUnixNano": $timestamp,
              "endTimeUnixNano": $(($timestamp + 1000000000)),
              "attributes": [
                {"key": "service.name", "value": {"stringValue": "trace-service"}},
                {"key": "trace.name", "value": {"stringValue": "Root Span Example"}},
                {"key": "http.method", "value": {"stringValue": "GET"}},
                {"key": "http.url", "value": {"stringValue": "/trace-test"}}
              ]
            }
          ]
        }
      ]
    }
  ]
}
EOF
}

# Función para enviar un log directamente a Fluent Bit
send_log() {
  local trace_id="$1"
  local span_id="$2"
  local timestamp="$3"
  local severity=$(random_severity_level)

  echo "Enviando log:"
  echo "  TraceID: $trace_id"
  echo "  SpanID: $span_id"
  echo "  Severity: $severity"
  echo "  Timestamp: $timestamp"

  curl -s -X POST "http://localhost:4320" \
    -H "Content-Type: application/json" \
    -d "{
      \"timestamp\": $timestamp,
      \"traceId\": \"$trace_id\",
      \"spanId\": \"$span_id\",
      \"level\": \"$severity\",
      \"severity_number\": 3,
      \"service\": \"my-app\",
      \"job\": \"fluentbit\",
      \"message\": \"This is a $severity log correlated with the trace\",
      \"method\": \"GET\",
      \"url\": \"/trace-test\",
      \"trace_flags\": 0
    }"
}

# Generar y enviar datos
printf "Enviando datos...\n"
current_timestamp=$(generate_timestamp)
i=0
while [ $i -lt "$DATA_COUNT" ]; do
  # Generar IDs con longitudes correctas
  trace_id=$(generate_trace_id)
  span_id=$(generate_span_id)
  parent_span_id=$(generate_span_id)

  # Enviar trazas
  send_trace "$trace_id" "$span_id" "$parent_span_id" "$current_timestamp"
  # Enviar log asociado al mismo trace_id y span_id
  send_log "$trace_id" "$span_id" "$current_timestamp"

  # Incrementar el timestamp con el intervalo definido
  current_timestamp=$((current_timestamp + INTERVAL_NS))

  i=$((i + 1))
  sleep 0.1

  if [ $((i % 10)) -eq 0 ]; then
    printf ".\n"
  fi
done

printf "\nDatos enviados: $DATA_COUNT\n"
