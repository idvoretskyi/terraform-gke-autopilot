package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var (
	// Version is injected at build time via -ldflags="-X main.Version=x.y.z"
	Version = "1.0.0"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", homeHandler)
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/api/info", infoHandler)

	srv := &http.Server{
		Addr:    ":" + port,
		Handler: mux,
	}

	serverCtx, serverStopCtx := context.WithCancel(context.Background())
	defer serverStopCtx()

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM, syscall.SIGQUIT)
	go func() {
		<-sig

		// Allow up to 30 seconds for in-flight requests to complete
		shutdownCtx, cancel := context.WithTimeout(serverCtx, 30*time.Second)
		defer cancel()

		go func() {
			<-shutdownCtx.Done()
			if shutdownCtx.Err() == context.DeadlineExceeded {
				log.Fatal("graceful shutdown timed out, forcing exit")
			}
		}()

		log.Println("shutdown signal received, draining connections...")
		if err := srv.Shutdown(shutdownCtx); err != nil {
			log.Fatal(err)
		}
		serverStopCtx()
	}()

	log.Printf("server listening on port %s", port)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}

	<-serverCtx.Done()
	log.Println("server stopped")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	const tmpl = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Demo Go App</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
    .info { background: #f0f0f0; padding: 20px; margin: 20px 0; border-radius: 5px; }
  </style>
</head>
<body>
  <h1>Demo Go Application</h1>
  <p>Sample application deployed on GKE Autopilot.</p>
  <div class="info">
    <p><strong>Server Time:</strong> %s</p>
    <p><strong>Hostname:</strong> %s</p>
  </div>
  <h3>Endpoints</h3>
  <ul>
    <li><a href="/">GET /</a> — this page</li>
    <li><a href="/health">GET /health</a> — health check (JSON)</li>
    <li><a href="/api/info">GET /api/info</a> — application info (JSON)</li>
  </ul>
</body>
</html>`

	hostname, _ := os.Hostname()
	fmt.Fprintf(w, tmpl, time.Now().UTC().Format("2006-01-02 15:04:05 UTC"), hostname)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status":    "healthy",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"application": "demo-go-app",
		"version":     Version,
		"hostname":    hostname,
		"timestamp":   time.Now().UTC().Format(time.RFC3339),
		"environment": os.Getenv("ENVIRONMENT"),
	})
}
