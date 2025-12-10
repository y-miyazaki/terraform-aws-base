# Dockerfile
FROM golang:1.22-bookworm@sha256:3d699e4d15d0f8f13c9195c0632a16702b8cbdece2955af1c23b37ae5d55a253 AS builder
WORKDIR /app

COPY test/go/server/main.go ./
RUN GOOS=linux GOARCH=amd64 go build -o server main.go

FROM debian:bookworm-slim@sha256:b4aa902587c2e61ce789849cb54c332b0400fe27b1ee33af4669e1f7e7c3e22f
WORKDIR /app
COPY --from=builder /app/server ./server
EXPOSE 8080
CMD ["/app/server"]
