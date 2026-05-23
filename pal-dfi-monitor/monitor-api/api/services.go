package api

import (
	"net/http"
	"pal-dfi-monitor/config"
	"time"

	"github.com/gin-gonic/gin"
)

type ServiceStatus struct {
	Name   string `json:"name"`
	URL    string `json:"url"`
	Status string `json:"status"`
}

func GetServices(c *gin.Context) {
	client := &http.Client{Timeout: 3 * time.Second}
	endpoints := config.AppEndpoints()

	result := make([]ServiceStatus, 0, len(endpoints))
	for _, endpoint := range endpoints {
		status := "down"
		resp, err := client.Get(endpoint.URL)
		if err == nil {
			if resp.StatusCode >= 200 && resp.StatusCode < 300 {
				status = "up"
			}
			resp.Body.Close()
		}

		result = append(result, ServiceStatus{
			Name:   endpoint.Name,
			URL:    endpoint.URL,
			Status: status,
		})
	}

	c.JSON(200, result)
}
