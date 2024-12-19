# FROM otel/opentelemetry-collector-contrib:0.116.1

# COPY otel-collector-config.yaml /etc/otel-collector-config.yaml

# EXPOSE 1888 8888 8889 13133 4317 4318 55679

# CMD ["--config=/etc/otel-collector-config.yaml"]

FROM golang:1.23 as build
ARG  OTEL_VERSION=0.116.0
WORKDIR /app
COPY builder.yaml builder.yaml
RUN go install go.opentelemetry.io/collector/cmd/builder@v${OTEL_VERSION}
RUN CGO_ENABLED=0 builder --config=builder.yaml

FROM gcr.io/distroless/base-debian11
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY --from=build /app/bin/otelcol-custom /
# 4317 - default OTLP receiver
# 4318 - default HTTP receiver
EXPOSE 4317/tcp 4318/tcp

CMD ["/otelcol-custom", "--config=/etc/otel-collector-config.yaml"]