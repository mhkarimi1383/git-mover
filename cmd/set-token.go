package cmd

import (
	"encoding/json"
	"errors"
	"fmt"
	"git-mover/constants"
	"git-mover/models"
	"io/ioutil"
	"regexp"

	"github.com/manifoldco/promptui"

	"github.com/spf13/cobra"
)

var setTokenCmd = &cobra.Command{
	Use:   "set-token",
	Short: "Command for store Gitlab api token",
	Long:  "Command for store Gitlab api token",
	Run: func(cmd *cobra.Command, args []string) {
		var (
			srcGitlabAPIAddress string
			srcGitlabAPIToken   string
			dstGitlabAPIAddress string
			dstGitlabAPIToken   string
			errInput            error
		)

		validateAPIAddress := func(url string) error {
			var re = regexp.MustCompile(constants.VALID_URL_REGEX)
			if !re.MatchString(url) {
				return errors.New("api address is incorrect")
			}
			return nil
		}

		validateToken := func(token string) error {
			if len(token) < 5 {
				return errors.New("token is incorrect")
			}
			return nil
		}

		srcAPIAddressPrompt := promptui.Prompt{
			Label:    "Source Gitlab api address",
			Validate: validateAPIAddress,
		}
		srcGitlabAPIAddress, errInput = srcAPIAddressPrompt.Run()
		if errInput != nil {
			fmt.Println(errInput.Error())
			return
		}

		srcTokenPrompt := promptui.Prompt{
			Label:    "Source Gitlab api token",
			Validate: validateToken,
		}
		srcGitlabAPIToken, errInput = srcTokenPrompt.Run()
		if errInput != nil {
			fmt.Println(errInput.Error())
			return
		}

		dstAPIAddressPrompt := promptui.Prompt{
			Label:    "Destination Gitlab api address",
			Validate: validateAPIAddress,
		}
		dstGitlabAPIAddress, errInput = dstAPIAddressPrompt.Run()
		if errInput != nil {
			fmt.Println(errInput.Error())
			return
		}

		dstTokenPrompt := promptui.Prompt{
			Label:    "Destination Gitlab api token",
			Validate: validateToken,
		}
		dstGitlabAPIToken, errInput = dstTokenPrompt.Run()
		if errInput != nil {
			fmt.Println(errInput.Error())
			return
		}

		jsonData := models.TokensAndAPIAdressesStruct{
			Src: models.TokenAndAPIAddress{
				APIAddress: srcGitlabAPIAddress,
				APIToken:   srcGitlabAPIToken,
			},
			Dst: models.TokenAndAPIAddress{
				APIAddress: dstGitlabAPIAddress,
				APIToken:   dstGitlabAPIToken,
			},
		}

		jsonIndented, _ := json.MarshalIndent(jsonData, "", "  ")

		jsonPath, err := constants.CRED_FILE_PATH()
		if err != nil {
			fmt.Println(err.Error())
			return
		}

		err = ioutil.WriteFile(jsonPath, jsonIndented, 0644)
		if err != nil {
			fmt.Println(err.Error())
			return
		}

		fmt.Printf("Credentials stored in: %s\n", jsonPath)
	},
}

func init() {
	rootCmd.AddCommand(setTokenCmd)
}
