package main

import (
	"pal-dfi-monitor/api"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	apiGroup := r.Group("/api")
	{
		apiGroup.GET("/health", api.Health)
		apiGroup.GET("/containers", api.GetContainers)
		apiGroup.GET("/transactions", api.GetTransactions)
		apiGroup.GET("/services", api.GetServices)
	}
}
