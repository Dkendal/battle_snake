package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type H map[string]interface{}

func start(w http.ResponseWriter, r *http.Request) {
	data := H{
		"name":  "simple-go-example-snake",
		"color": "#123456",
	}

	json.NewEncoder(w).Encode(data)
}

func move(w http.ResponseWriter, r *http.Request) {
	data := H{
		"move": "up",
	}

	json.NewEncoder(w).Encode(data)
}

func main() {
	http.HandleFunc("/start", start)
	http.HandleFunc("/move", move)

	log.Fatal(http.ListenAndServe(":8080", nil))
}
