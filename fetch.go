package main

import (
	"net/http"
	"log"
	"fmt"
	"bufio"
	"strings"
	"io/ioutil"
	"path"
)

const server = "http://192.168.178.29:49152/"

func main() {
	resp, err := http.Get(server + "index.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	
	fetched := 0
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		fetch(scanner.Text())
		fetched++
		if fetched == 1 {
			break
		}
	}
	if err := scanner.Err(); err != nil {
		log.Fatal("reading body", err)
	}
}

func fetch(s string) {
	chunks := strings.Split(s, "|")
	if len(chunks) != 2 {
		log.Printf("bad index line %q", s)
		return
	}
	name, fullPath := chunks[0], chunks[1]
	fmt.Printf("%s\n%s \n\n", name, fullPath)

	resp, err := beyonwizGet(path.Join(path.Dir(fullPath), "header.tvwiz"))
	if err != nil {
		log.Fatal(err)
	}
	body, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		log.Fatal("reading header", err)
	}
	unpackHeader(body)
}


// beyonwizGet is http.Get, working around Beyonwiz breakage. 
// Beyonwiz will accept %2B but NOT '+' inside the URL path (despite standards).
// Go libraries insist on sending '+', unless we use the Opaque part of URL object,
// requiring explicit Request and Client.
func beyonwizGet(u string) (*http.Response, error) {
	req, err := http.NewRequest("GET", server + u, nil)
	if err != nil {
		log.Fatal(err)
	}
	req.URL.Opaque= strings.Replace(req.URL.RequestURI(), "+", "%2B", -1)
	req.URL.Path = ""
		
	return http.DefaultClient.Do(req)
}
