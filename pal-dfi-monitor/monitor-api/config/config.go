package config

import "os"

type AppEndpoint struct {
	Name string `json:"name"`
	URL  string `json:"url"`
}

func AppEndpoints() []AppEndpoint {
	return []AppEndpoint{
		{Name: "jawwal", URL: getEnv("JAWWAL_URL", "http://jawwal:8080/health")},
		{Name: "moi", URL: getEnv("MOI_URL", "http://moi:8080/health")},
		{Name: "pma", URL: getEnv("PMA_URL", "http://pma:8080/health")},
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
