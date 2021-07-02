package models

type TokensAndAPIAdressesStruct struct {
	Src TokenAndAPIAddress
	Dst TokenAndAPIAddress
}

type TokenAndAPIAddress struct {
	APIAddress string
	APIToken   string
}
