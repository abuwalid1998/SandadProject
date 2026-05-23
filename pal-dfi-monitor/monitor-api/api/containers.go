package api

import (
	"pal-dfi-monitor/services"

	"github.com/gin-gonic/gin"
)

func GetContainers(c *gin.Context) {
	containers, err := services.ListContainers()
	if err != nil {
		c.JSON(500, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(200, containers)
}
