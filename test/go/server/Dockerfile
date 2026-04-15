# Dockerfile
FROM golang:1.25-bookworm@sha256:29e59af995c51a5bf63d072eca973b918e0e7af4db0e4667aa73f1b8da1a6d8c AS builder
WORKDIR /app

COPY test/go/server/main.go ./
RUN GOOS=linux GOARCH=amd64 go build -o server main.go

FROM debian:bookworm-slim@sha256:4724b8cc51e33e398f0e2e15e18d5ec2851ff0c2280647e1310bc1642182655d
WORKDIR /app
COPY --from=builder /app/server ./server
EXPOSE 8080
CMD ["/app/server"]
