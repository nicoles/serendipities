// Moves API specific
package main

import (
	"fmt"
	"golang.org/x/oauth2"
)

const (
	MovesAuthURL     = "https://api.moves-app.com/oauth/v1/authorize"
	MovesTokenURL    = "https://api.moves-app.com/oauth/v1/access_token"
	MovesTokenURLFmt = "https://api.moves-app.com/oauth/v1/access_token?grant_type=authorization_code&code=%s&client_id=%s&client_secret=%s"
)

func check(err error) {
	if nil != err {
		panic(err)
	}
}

type IndexData struct {
	MovesURL string
	Token    *oauth2.Token
}

type MovesAPI struct {
	Config   *oauth2.Config
	AuthCode string
	Token    *oauth2.Token
}

// Constructor
func NewMovesAPI(key, secret string) *MovesAPI {
	m := &MovesAPI{}
	fmt.Println("Preparing Moves API:")
	fmt.Println("Moves Key: ", key)
	fmt.Println("Moves Secret: ", secret)
	// Prepare Oauth config for Moves
	m.Config = &oauth2.Config{
		ClientID:     key,
		ClientSecret: secret,
		Scopes:       []string{"activity location"},
		Endpoint: oauth2.Endpoint{
			AuthURL:  MovesAuthURL,
			TokenURL: MovesTokenURL,
		},
	}
	return m
}

func (m *MovesAPI) GetAuthURL() string {
	if nil == m.Config {
		panic("Config should never be nil")
	}
	return m.Config.AuthCodeURL("state")
}

// Exchange a code for a Token to authorize for Moves API.
func (m *MovesAPI) GetToken() error {
	if "" == moves.AuthCode {
		panic("GetToken should never be called without AuthCode.")
	}
	tokenURL := setTokenURL(m.AuthCode, m.Config.ClientID, m.Config.ClientSecret)
	m.Config.Endpoint.TokenURL = tokenURL
	// Obtain moves token.
	received, er := m.Config.Exchange(oauth2.NoContext, m.AuthCode)
	if nil != er || nil == received {
		return er
	}
	// Set the new Token and eliminate obsolete auth code.
	m.Token = received
	m.AuthCode = ""
	return nil
}

// For some reason, Moves requires the query string with the POST...
func setTokenURL(code, id, secret string) string {
	return fmt.Sprintf(MovesTokenURLFmt, code, id, secret)
}
