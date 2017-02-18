package run

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"

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

func Command(command string, output chan string) {
	// Run the command via sh to allow for basic shell functionality
	cmd := exec.Command("sh", "-c", command)

	// Start a pseudo terminal to allow us to capture output as if we were a shell
	file, err := pty.Start(cmd)

	if err != nil {
		log.Fatal(err)
	}

	scanner := bufio.NewScanner(file)

	// Read in each line of output
	for scanner.Scan() {
		output <- scanner.Text()
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
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

	close(output)
	os.Exit(exitStatus)
}
