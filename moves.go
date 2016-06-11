// Moves API specific
package main

import (
	"fmt"
  "errors"
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
	if nil != moves.Token {
    return errors.New("MovesAPI already has Token.")
	}
	if "" == moves.AuthCode {
    return errors.New("MovesAPI has no AuthCode available yet.")
	}
	// For some reason, Moves requires entries in the query string as well as the
	// POST, so override the TokenURL.
	m.Config.Endpoint.TokenURL = fmt.Sprintf(MovesTokenURLFmt,
		m.AuthCode, m.Config.ClientID, m.Config.ClientSecret)

	// Exchange AuthCode for Moves Token.
	received, er := m.Config.Exchange(oauth2.NoContext, m.AuthCode)
	if nil != er || nil == received {
		return er
	}
	m.AuthCode = ""
	m.Token = received
	return nil
}
