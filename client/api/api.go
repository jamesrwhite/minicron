package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

type Client interface {
	Init(req *InitRequest) (*InitResponse, error)
	Start(req *StartRequest) error
	Output(req *OutputRequest) error
	Finish(req *FinishRequest) error
	Exit(req *ExitRequest) error
}

type client struct {
	http *http.Client
}

type InitRequest struct {
	User      string `json:"user"`
	Command   string `json:"command"`
	Hostname  string `json:"hostname"`
	Timestamp int64  `json:"timestamp"`
}

type InitResponse struct {
	ExecutionID int `json:"execution_id"`
}

type StartRequest struct {
	ExecutionID int   `json:"execution_id"`
	Timestamp   int64 `json:"timestamp"`
}

type OutputRequest struct {
	ExecutionID int    `json:"execution_id"`
	Seq         int    `json:"seq"`
	Output      string `json:"output"`
	Timestamp   int64  `json:"timestamp"`
}

type FinishRequest struct {
	ExecutionID int   `json:"execution_id"`
	Timestamp   int64 `json:"timestamp"`
}

type ExitRequest struct {
	ExecutionID int   `json:"execution_id"`
	ExitStatus  int   `json:"exit_status"`
	Timestamp   int64 `json:"timestamp"`
}

// TODO: inject/get config here
var GetClient = func() (Client, error) {
	// TODO: review https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/#clienttimeouts
	// and set more fine grained timeouts/connection pool handling
	return &client{
		http: &http.Client{
			Timeout: 15 * time.Second, // basic timeout, covers entire request
		},
	}, nil
}

func (c *client) Init(req *InitRequest) (*InitResponse, error) {
	resp, err := c.post("/execution/init", req)
	initResponse := &InitResponse{}

	if err != nil {
		return initResponse, err
	}

	// Try and unmarshal the response
	err = json.Unmarshal(resp, initResponse)

	if err != nil {
		return initResponse, err
	}

	return initResponse, nil
}

func (c *client) Start(req *StartRequest) error {
	_, err := c.post("/execution/start", req)

	return err
}

func (c *client) Output(req *OutputRequest) error {
	_, err := c.post("/execution/output", req)

	return err
}

func (c *client) Finish(req *FinishRequest) error {
	_, err := c.post("/execution/finish", req)

	return err
}

func (c *client) Exit(req *ExitRequest) error {
	_, err := c.post("/execution/exit", req)

	return err
}

func (c *client) post(method string, body interface{}) ([]byte, error) {
	// Build the URL for the request
	// TODO: get base url from config
	url := fmt.Sprintf("http://127.0.0.1:9292/api/1.0%s", method)

	// Marshal the request body struct to json
	reqJSON, err := json.Marshal(body)

	fmt.Println("req: " + string(reqJSON))

	// Build the requests
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(reqJSON))

	if err != nil {
		return []byte{}, err
	}

	// Add the api token
	// TODO: get this from config
	req.Header.Add("X-API-Key", "RsMZbz4zSJM7vfkAJ8P7CaHkYcdCSr8HF1whHRNxQv5m9ulWkaszImV9x72lZX-Q")
	req.Header.Add("Content-Type", "application/json")

	// Execute the request
	resp, err := c.http.Do(req)

	if err != nil {
		return []byte{}, err
	}

	// Read in the response body to a []byte
	defer resp.Body.Close()
	respBody, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		return []byte{}, err
	}

	fmt.Println("res: " + string(respBody))

	return respBody, nil
}
