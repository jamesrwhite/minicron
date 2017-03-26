package run

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"strings"
	"syscall"
	"time"

	"github.com/jamesrwhite/minicron/api"

	"github.com/kr/pty"
)

func Parse(command []string) (string, error) {
	if len(command) == 0 {
		return "", fmt.Errorf("No command provided")
	}

	// Join the command up into one string
	fullCommand := strings.Join(command, " ")

	if strings.TrimSpace(fullCommand) == "" {
		return "", fmt.Errorf("Empty command provided")
	}

	return fullCommand, nil
}

func Command(command string, output chan string) (int, error) {
	// Get the fqdn of the host we're running on
	hostname, err := os.Hostname()

	if err != nil {
		return 1, fmt.Errorf("Unable to determine hostname: %s", err.Error())
	}

	// Get the user we're running as
	user, err := user.Current()

	if err != nil {
		return 1, fmt.Errorf("Unable to determine user: %s", err.Error())
	}

	username := user.Username

	// Get an api client instance
	client, err := api.GetClient()

	if err != nil {
		return 1, fmt.Errorf("Unable to initialise api client: %s", err.Error())
	}

	// Mark the executino as being initialised
	execution, _ := client.Init(&api.InitRequest{
		User:      username,
		Command:   command,
		Hostname:  hostname,
		Timestamp: time.Now().Unix(),
	})

	// Run the command via sh to allow for basic shell functionality
	cmd := exec.Command("sh", "-c", command)

	// Start a pseudo terminal to allow us to capture output as if we were a shell
	file, err := pty.Start(cmd)

	if err != nil {
		return 1, err
	}

	// Mark the execution as having started
	err = client.Start(&api.StartRequest{
		ExecutionID: execution.ExecutionID,
		Timestamp:   time.Now().Unix(),
	})

	if err != nil {
		return 1, err
	}

	scanner := bufio.NewScanner(file)

	// Read in each line of output
	for scanner.Scan() {
		// Get the line of execution output
		line := scanner.Text()

		// Publish it onto the output channel
		output <- line

		// Send the output to the api
		// TODO: do this async
		err = client.Output(&api.OutputRequest{
			ExecutionID: execution.ExecutionID,
			Output:      line,
			Timestamp:   time.Now().Unix(),
		})

		if err != nil {
			return 1, err
		}
	}

	// Mark the execution as having finished
	// TODO: should this be before/after the below error?
	err = client.Finish(&api.FinishRequest{
		ExecutionID: execution.ExecutionID,
		Timestamp:   time.Now().Unix(),
	})

	if err := scanner.Err(); err != nil {
		return 1, err
	}

	// Wait for the command to finish so we can determinse it's exit status
	err = cmd.Wait()

	var exitStatus int

	if err != nil {
		// Default the exit status to 1
		exitStatus = 1

		// Try to get the real exit code - http://stackoverflow.com/a/40770011/483271
		if exitError, ok := err.(*exec.ExitError); ok {
			status := exitError.Sys().(syscall.WaitStatus)
			exitStatus = status.ExitStatus()
		}
	} else {
		exitStatus = 0
	}

	// Mark the execution as having finished
	// TODO: should this be before/after the below error?
	err = client.Exit(&api.ExitRequest{
		ExecutionID: execution.ExecutionID,
		ExitStatus:  exitStatus,
		Timestamp:   time.Now().Unix(),
	})

	if err != nil {
		return exitStatus, err
	}

	// Close the output channel to signify we have no more output to send
	// TODO: currently this blocks the program from exiting in cmd/run.go which is
	// just a happy accident really
	close(output)

	return exitStatus, nil
}
