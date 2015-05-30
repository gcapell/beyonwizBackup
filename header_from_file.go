package main

import "io/ioutil"

func main() {
	b, err := ioutil.ReadFile("testdata/header")
	unpackHeader(b)
}
