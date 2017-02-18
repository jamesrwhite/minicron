package cmd

import (
	"fmt"
	"log"
	"os"

	"github.com/jamesrwhite/minicron/run"
	"github.com/spf13/cobra"
)

// runCmd represents the run command
var runCmd = &cobra.Command{
	Use:   "run",
	Short: "A brief description of your command",
	Run: func(cmd *cobra.Command, args []string) {
		// Try and parse the command
		command, err := run.Parse(args)

		if err != nil {
			log.Fatal(err)

			os.Exit(1)
		}

		// Create a channel we can listen for command output on
		output := make(chan string)

		// Execute the command
		go run.Command(command, output)

		// Listen and print any output from the command
		for line := range output {
			fmt.Println(line)
		}
	},
}

func init() {
	RootCmd.AddCommand(runCmd)

	runCmd.Flags().BoolP("dry-run", "d", false, "Run the command without sending the output to the server")
}
