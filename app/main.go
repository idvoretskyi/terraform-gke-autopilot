package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/info", infoHandler)

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
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
	fmt.Fprintf(w, `{"status": "healthy", "timestamp": "%s"}`, time.Now().Format(time.RFC3339))
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	
	info := fmt.Sprintf(`{
		"application": "demo-go-app",
		"version": "1.0.0",
		"hostname": "%s",
		"timestamp": "%s",
		"environment": "%s"
	}`, hostname, time.Now().Format(time.RFC3339), os.Getenv("ENVIRONMENT"))
	
	fmt.Fprint(w, info)
}