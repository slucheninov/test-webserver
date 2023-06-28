// generation chatGPT
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type Data struct {
	Status int `json:"status"`
}

var httpStatusCode int = 200

func main() {
	// Define the routes and their corresponding handlers
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/api", apiHandler)
	http.HandleFunc("/health", healthCheckHandler)

	// Start the server
	log.Println("Server started on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {

	w.WriteHeader(httpStatusCode)
	fmt.Fprint(w, "Welcome to the home page!")
}

func apiHandler(w http.ResponseWriter, r *http.Request) {
	// Handle only POST requests
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		fmt.Fprint(w, "Method not allowed")
		return
	}

	// Parse the JSON request body
	var data Data
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Failed to parse JSON: %v", err)
		return
	}

	statusCode := http.StatusCreated
	httpStatusCode = data.Status

	w.WriteHeader(statusCode)
	fmt.Fprint(w, "Change status")
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	statusCode := http.StatusOK
	message := "Server is healthy"

	// Check if the server is healthy
	// You can add your custom logic here to determine the health status
	// For example, check the database connection, external service availability, etc.
	isHealthy := true

	if !isHealthy {
		statusCode = http.StatusInternalServerError
		message = "Server is unhealthy"
	}

	w.WriteHeader(statusCode)
	fmt.Fprint(w, message)
}
