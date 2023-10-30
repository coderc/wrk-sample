package main

import (
	"fmt"
	"io"
	"net/http"
	"sync/atomic"

	"github.com/gin-gonic/gin"
)

func main() {
	total := atomic.Int64{}
	r := gin.New()
	r.Match([]string{http.MethodPost, http.MethodGet}, "/dsp/dsp_dispatcher", func(c *gin.Context) {
		body, _ := io.ReadAll(c.Request.Body)

		fmt.Printf("total: [%10d], param: [%s]  exchange: [%s]  body: [%s]\n", total.Add(1), c.Request.URL.RawQuery, c.Query("exchange"), string(body[:40]))
	})

	r.Run(":8088")
}
