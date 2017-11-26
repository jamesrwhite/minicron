package commands

import (
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var verbose bool
var debug bool
var apiBase string
var apiKey string

// Initialise the root cli command
var RootCommand = &cobra.Command{
	Use: "minicron",
}

func init() {
	// Add all global (persistent) flags to the root command
	RootCommand.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")
	RootCommand.PersistentFlags().BoolVarP(&debug, "debug", "d", false, "debug mode")
	RootCommand.PersistentFlags().StringVarP(&apiBase, "api-base", "b", "", "api base endpoint")
	RootCommand.PersistentFlags().StringVarP(&apiKey, "api-key", "k", "", "api key")

	// Bind the persistent commands to viper (config)
	viper.BindPFlag("verbose", RootCommand.PersistentFlags().Lookup("verbose"))
	viper.BindPFlag("debug", RootCommand.PersistentFlags().Lookup("debug"))
	viper.BindPFlag("apiBase", RootCommand.PersistentFlags().Lookup("api-base"))
	viper.BindPFlag("apiKey", RootCommand.PersistentFlags().Lookup("api-key"))

	// Add all sub-commands
	RootCommand.AddCommand(RunCommand)
}
