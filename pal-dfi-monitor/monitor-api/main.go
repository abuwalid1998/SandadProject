package main

import (
	"log"
	"pal-dfi-monitor/fabric"

	"github.com/gin-gonic/gin"
)

func main() {
	go fabric.StartListener()

	r := gin.Default()

	RegisterRoutes(r)

	log.Println("monitor-api listening on :8091")
	r.Run(":8091")
}
