package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/", handleWebhook)
	log.Printf("${provider_name} webhook handler listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleWebhook(w http.ResponseWriter, r *http.Request) {
	// TODO: implement ${provider_name} webhook handling.
	fmt.Fprintln(w, "ok")
}
