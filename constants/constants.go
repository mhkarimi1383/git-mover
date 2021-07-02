package constants

import (
	"errors"
	"fmt"
	"os"
)

func CRED_FILE_PATH() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", errors.New("Error in finding home directory.")
	}
	return fmt.Sprintf("%s/.git-mover.json", homeDir), nil
}

const VALID_URL_REGEX = `((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)`
