package api

import (
	"pal-dfi-monitor/fabric"

	"github.com/gin-gonic/gin"
)

func GetTransactions(c *gin.Context) {
	c.JSON(200, fabric.GetTransactionCache())
}
