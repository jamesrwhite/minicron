package api

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type Client interface {
	Init(req *InitRequest) (*InitResponse, error)
	Start(req *StartRequest) (*StartResponse, error)
	Output(req *OutputRequest) (*OutputResponse, error)
	Finish(req *FinishRequest) (*FinishResponse, error)
	Exit(req *ExitRequest) (*ExitResponse, error)
}

type client struct {
	http *http.Client
}

type coreApiResponse struct {
	Success bool     `json:"success"`
	Error   apiError `json:"error"`
}

type apiError struct {
	Message string `json:"message"`
}

type InitRequest struct {
	User      string `json:"user"`
	Command   string `json:"command"`
	Hostname  string `json:"hostname"`
	Timestamp int64  `json:"timestamp"`
}

type InitResponse struct {
	coreApiResponse
	Body struct {
		ExecutionID int `json:"execution_id"`
	}
}

type StartRequest struct {
	ExecutionID int   `json:"execution_id"`
	Timestamp   int64 `json:"timestamp"`
}

type StartResponse coreApiResponse

type OutputRequest struct {
	ExecutionID int    `json:"execution_id"`
	Seq         int    `json:"seq"`
	Output      string `json:"output"`
	Timestamp   int64  `json:"timestamp"`
}

type OutputResponse coreApiResponse

type FinishRequest struct {
	ExecutionID int   `json:"execution_id"`
	Timestamp   int64 `json:"timestamp"`
}

type FinishResponse coreApiResponse

type ExitRequest struct {
	ExecutionID int   `json:"execution_id"`
	ExitStatus  int   `json:"exit_status"`
	Timestamp   int64 `json:"timestamp"`
}

type ExitResponse coreApiResponse

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
	response, err := c.post("/execution/init", req, &InitResponse{})
	initResponse := response.(*InitResponse)

	if err != nil {
		return initResponse, err
	}

	if initResponse.Success == false {
		return initResponse, errors.New(initResponse.Error.Message)
	}

	return initResponse, nil
}

func (c *client) Start(req *StartRequest) (*StartResponse, error) {
	response, err := c.post("/execution/start", req, &StartResponse{})
	startResponse := response.(*StartResponse)

	if err != nil {
		return startResponse, err
	}

	if startResponse.Success == false {
		return startResponse, errors.New(startResponse.Error.Message)
	}

	return startResponse, nil
}

func (c *client) Output(req *OutputRequest) (*OutputResponse, error) {
	response, err := c.post("/execution/output", req, &OutputResponse{})
	outputResponse := response.(*OutputResponse)

	if err != nil {
		return outputResponse, err
	}

	if outputResponse.Success == false {
		return outputResponse, errors.New(outputResponse.Error.Message)
	}

	return outputResponse, nil
}

func (c *client) Finish(req *FinishRequest) (*FinishResponse, error) {
	response, err := c.post("/execution/finish", req, &FinishResponse{})
	finishResponse := response.(*FinishResponse)

	if err != nil {
		return finishResponse, err
	}

	if finishResponse.Success == false {
		return finishResponse, errors.New(finishResponse.Error.Message)
	}

	return finishResponse, nil
}

func (c *client) Exit(req *ExitRequest) (*ExitResponse, error) {
	response, err := c.post("/execution/exit", req, &ExitResponse{})
	exitResponse := response.(*ExitResponse)

	if err != nil {
		return exitResponse, err
	}

	if exitResponse.Success == false {
		return exitResponse, errors.New(exitResponse.Error.Message)
	}

	return exitResponse, nil
}

func (c *client) post(method string, reqBody interface{}, respStruct interface{}) (interface{}, error) {
	// Get the api base endpoint
	apiBase := viper.Get("apiBase")

	// Build the URL for the request
	url := fmt.Sprintf("%s%s", apiBase, method)

	// Marshal the request body struct to json
	reqJSON, err := json.Marshal(reqBody)

	if err != nil {
		log.WithFields(log.Fields{
			"method": method,
			"url":    url,
			"error":  err,
		}).Error("api_request")

		return respStruct, err
	}

	// Build the request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(reqJSON))

	if err != nil {
		log.WithFields(log.Fields{
			"method": method,
			"url":    url,
			"error":  err,
		}).Error("api_request")

		return respStruct, err
	}

	// Get the api key from config
	apiKey := viper.GetString("apiKey")

	// Add the api key and content type
	req.Header.Add("X-API-Key", apiKey)
	req.Header.Add("Content-Type", "application/json")

	log.WithFields(log.Fields{
		"method":  method,
		"url":     url,
		"apiKey":  apiKey,
		"payload": string(reqJSON),
	}).Debug("api_request")

	// Execute the request
	resp, err := c.http.Do(req)

	if err != nil {
		log.WithFields(log.Fields{
			"method":  method,
			"url":     url,
			"apiKey":  apiKey,
			"payload": string(reqJSON),
			"error":   err,
		}).Error("api_response")

		return respStruct, err
	}

	// Read in the response body to a []byte
	defer resp.Body.Close()
	respBody, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		log.WithFields(log.Fields{
			"method":  method,
			"url":     url,
			"apiKey":  apiKey,
			"payload": string(reqJSON),
			"error":   err,
		}).Error("api_response")

		return respStruct, err
	}

	log.WithFields(log.Fields{
		"method":   method,
		"url":      url,
		"apiKey":   apiKey,
		"payload":  string(reqJSON),
		"response": string(respBody),
	}).Debug("api_response")

	// Try and unmarshal the response
	err = json.Unmarshal(respBody, respStruct)

	if err != nil {
		return respStruct, err
	}

	return respStruct, nil
}
