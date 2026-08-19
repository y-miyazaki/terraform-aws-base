//revive:disable:comments-density reason: table-driven tests are self-explanatory via subtest names.
package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandler_WritesPlainTextResponse(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name       string
		method     string
		path       string
		wantCT     string
		wantBody   string
		wantStatus int
	}{
		{
			name:       "get root returns hello message",
			method:     http.MethodGet,
			path:       "/",
			wantStatus: http.StatusOK,
			wantCT:     "text/plain",
			wantBody:   "Hello from Go HTTP server!\n",
		},
		{
			name:       "get arbitrary path returns hello message",
			method:     http.MethodGet,
			path:       "/health",
			wantStatus: http.StatusOK,
			wantCT:     "text/plain",
			wantBody:   "Hello from Go HTTP server!\n",
		},
	}

	for i := range tests {
		tt := tests[i]
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			req := httptest.NewRequestWithContext(context.Background(), tt.method, tt.path, http.NoBody)
			rec := httptest.NewRecorder()

			handler(rec, req)

			if got := rec.Code; got != tt.wantStatus {
				t.Fatalf("handler(%s %s) status = %d, want %d", tt.method, tt.path, got, tt.wantStatus)
			}
			if got := rec.Header().Get("Content-Type"); got != tt.wantCT {
				t.Fatalf("handler(%s %s) Content-Type = %q, want %q", tt.method, tt.path, got, tt.wantCT)
			}
			if got := rec.Body.String(); got != tt.wantBody {
				t.Fatalf("handler(%s %s) body = %q, want %q", tt.method, tt.path, got, tt.wantBody)
			}
		})
	}
}
