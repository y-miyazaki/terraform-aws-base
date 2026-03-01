// main.go
// Simple HTTP server for Docker container
// Listens on port 8080 and responds with a plain text message
// ko publish --local --base-import-paths . && docker images | grep ko.local
// ./scripts/terraform/aws_upload_ecr.sh -i ko.local/server:latest test-server
package main

import (
	"fmt"
	"net/http"
)

// nolint:errcheck, unused, revive
func handler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintln(w, "Hello from Go HTTP server!")
}

// nolint:errcheck, forbidigo, gosec, revive
func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Starting Go HTTP server on :8080...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}
