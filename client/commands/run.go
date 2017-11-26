package commands

import (
	"fmt"
	"os"

	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"

	"github.com/jamesrwhite/minicron/client/run"
)

var RunCommand = &cobra.Command{
	Use:   "run",
	Short: "run the given command",
	Run: func(cmd *cobra.Command, args []string) {
		// Try and parse the command to run from the args we got
		command, err := run.Parse(args)

		if err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Fatal("run_parse")
		}

		// Create a channel we can listen for command output on
		output := make(chan string)

		var exitStatus int

		// Execute the command
		go func() {
			exitStatus, err = run.Command(command, output)

			if err != nil {
				log.WithFields(log.Fields{
					"error": err,
				}).Fatal("run_execute")
			}
		}()

		// Listen and print any output from the command
		for line := range output {
			fmt.Println(line)
		}

		// Exit with the exit status of the command
		os.Exit(exitStatus)
	},
}

func init() {}
