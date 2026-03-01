// main.go
// Simple Hello batch for Docker container
// ko publish --local --base-import-paths . && docker images | grep ko.local
// ./scripts/terraform/aws_upload_ecr.sh -i ko.local/batch:latest test-batch
package main

import (
	"fmt"
)

func main() {
	fmt.Println("Starting Hello batch")
}
