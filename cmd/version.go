package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Version of git-mover cli tool",
	Long:  `Version of git-mover cli tool`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("git-mover cli v0.01")
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
