package main

import (
	log "github.com/sirupsen/logrus"

	"github.com/jamesrwhite/minicron/client/commands"
)

func main() {
	log.SetLevel(log.DebugLevel)
	log.Debug("startup")

	err := commands.RootCommand.Execute()

	if err != nil {
		log.WithFields(log.Fields{
			"error": err,
		}).Fatal("startup")
	}
}
