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
	// Version can be injected at build time
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

	// Server run context
	serverCtx, serverStopCtx := context.WithCancel(context.Background())

	// Listen for syscall signals for process to interrupt/quit
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM, syscall.SIGQUIT)
	go func() {
		<-sig

		// Shutdown signal with grace period of 30 seconds
		shutdownCtx, _ := context.WithTimeout(serverCtx, 30*time.Second)

		go func() {
			<-shutdownCtx.Done()
			if shutdownCtx.Err() == context.DeadlineExceeded {
				log.Fatal("graceful shutdown timed out.. forcing exit.")
			}
		}()

		// Trigger graceful shutdown
		log.Println("Received shutdown signal, shutting down gracefully...")
		err := srv.Shutdown(shutdownCtx)
		if err != nil {
			log.Fatal(err)
		}
		serverStopCtx()
	}()

	log.Printf("Starting server on port %s", port)
	err := srv.ListenAndServe()
	if err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}

	// Wait for server context to be stopped
	<-serverCtx.Done()
	log.Println("Server exited")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	html := `
<!DOCTYPE html>
<html>
<head>
    <title>Demo Go App</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .container { text-align: center; }
        .info { background: #f0f0f0; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .endpoints { text-align: left; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Demo Go Application</h1>
        <p>Welcome to the sample Go application deployed on GKE Autopilot!</p>
        
        <div class="info">
            <h3>Application Info</h3>
            <p><strong>Server Time:</strong> %s</p>
            <p><strong>Hostname:</strong> %s</p>
        </div>

        <div class="endpoints">
            <h3>Available Endpoints:</h3>
            <ul>
                <li><a href="/">GET / - This page</a></li>
                <li><a href="/health">GET /health - Health check</a></li>
                <li><a href="/api/info">GET /api/info - JSON application info</a></li>
            </ul>
        </div>

        <p><em>This is a demonstration application for the GKE Autopilot cluster.</em></p>
    </div>
</body>
</html>
`
	hostname, _ := os.Hostname()
	fmt.Fprintf(w, html, time.Now().Format("2006-01-02 15:04:05 UTC"), hostname)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"status":    "healthy",
		"timestamp": time.Now().Format(time.RFC3339),
	})
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	info := map[string]string{
		"application": "demo-go-app",
		"version":     Version,
		"hostname":    hostname,
		"timestamp":   time.Now().Format(time.RFC3339),
		"environment": os.Getenv("ENVIRONMENT"),
	}

	json.NewEncoder(w).Encode(info)
}
