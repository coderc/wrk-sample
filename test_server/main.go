package main

import (
	"fmt"
	"io"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.New()
	r.POST("/dsp/dsp_dispatcher", func(c *gin.Context) {
		body, _ := io.ReadAll(c.Request.Body)

		fmt.Printf("param: %s\nexchange: %s\nbody: %s\n", c.Request.URL.RawQuery, c.Query("exchange"), string(body))
	})

	r.Run(":8088")
}
