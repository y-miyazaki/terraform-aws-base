//revive:disable:comments-density reason: table-driven tests are self-explanatory via subtest names.
package main

import (
	"bytes"
	"io"
	"os"
	"testing"
)

func TestMain_PrintsStartupMessage(t *testing.T) {
	tests := []struct {
		name string
		want string
	}{
		{name: "prints startup line", want: "Starting Hello batch\n"},
	}

	for i := range tests {
		tt := tests[i]
		t.Run(tt.name, func(t *testing.T) {
			// Omit t.Parallel(): captures os.Stdout (TBL-06).

			oldStdout := os.Stdout
			reader, writer, pipeErr := os.Pipe()
			if pipeErr != nil {
				t.Fatalf("os.Pipe() error = %v", pipeErr)
			}
			os.Stdout = writer //nolint:reassign // capture main() stdout in unit test

			done := make(chan struct{})
			go func() {
				defer close(done)
				main()
				_ = writer.Close()
			}()

			var output bytes.Buffer
			if _, copyErr := io.Copy(&output, reader); copyErr != nil {
				t.Fatalf("io.Copy() error = %v", copyErr)
			}
			<-done
			os.Stdout = oldStdout //nolint:reassign // restore stdout after capture

			if got := output.String(); got != tt.want {
				t.Fatalf("main() stdout = %q, want %q", got, tt.want)
			}
		})
	}
}
