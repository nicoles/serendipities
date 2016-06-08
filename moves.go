package main

import (
	"encoding/json"
	"fmt"
	"golang.org/x/oauth2"
	"html/template"
	"net/http"
	"os"
)

const (
	MovesAuthURL     = "https://api.moves-app.com/oauth/v1/authorize"
	MovesTokenURL    = "https://api.moves-app.com/oauth/v1/access_token"
	MovesTokenURLFmt = "https://api.moves-app.com/oauth/v1/access_token?grant_type=authorization_code&code=%s&client_id=%s&client_secret=%s"
)

var movesAuthURL string = ""
var config *oauth2.Config
var code string
var token *oauth2.Token

func check(err error) {
	if nil != err {
		panic(err)
	}
}

func getToken() (*oauth2.Token, error) {
	tokenURL := setTokenURL(code, config.ClientID, config.ClientSecret)
	config.Endpoint.TokenURL = tokenURL
	// Obtain moves token.
	received, er := config.Exchange(oauth2.NoContext, code)
	if nil != er || nil == received {
		return nil, er
	}
	token = received
	code = ""
	return token, nil
}

// For some reason, Moves requires the query string with the POST...
func setTokenURL(code, id, secret string) string {
	return fmt.Sprintf(MovesTokenURLFmt, code, id, secret)
}

func handler(w http.ResponseWriter, r *http.Request) {
	url := config.AuthCodeURL("state")
	fmt.Println("\nUsing Moves API URL: \n", url)
	data := struct {
		MovesURL string
		Token    *oauth2.Token
	}{
		url, token,
	}
	fmt.Println(data)
	t, _ := template.ParseFiles("templates/index.html")
	t.Execute(w, data)
}

// Callback once moves has authorized.
func authHandler(w http.ResponseWriter, r *http.Request) {
  if nil != token {
    fmt.Fprintf(w, "Already authorized with Moves.")
    return
  }

	// Check for auth error.
	errors := r.FormValue("errors")
	if "" != errors {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	state := r.FormValue("state")
	if state != "state" {
		fmt.Fprintf(w, "Invalid State")
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	code = r.FormValue("code")
	http.Redirect(w, r, "/gettoken", 301)
}

func tokenHandler(w http.ResponseWriter, r *http.Request) {
  if nil != token {
    fmt.Fprintf(w, "Already authorized with Moves.")
    return
  }
	if "" == code {
		fmt.Fprintf(w, "No auth code yet.")
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	token, err := getToken()
	if nil == token {
		fmt.Fprintf(w, "Problem getting token.\n")
		fmt.Fprintf(w, err.Error())
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	b, _ := json.Marshal(token)
	fmt.Fprintf(w, "Moves Token:  "+string(b))
}

func main() {

	key := os.Getenv("MOVES_KEY")
	secret := os.Getenv("MOVES_SECRET")
	fmt.Println("Moves Key: ", key)
	fmt.Println("Moves Secret: ", secret)

	config = &oauth2.Config{
		// config = {
		ClientID:     key,
		ClientSecret: secret,
		Scopes:       []string{"activity location"},
		Endpoint: oauth2.Endpoint{
			AuthURL:  MovesAuthURL,
			TokenURL: MovesTokenURL,
		},
	}
	http.HandleFunc("/", handler)
	http.HandleFunc("/auth/moves/callback", authHandler)
	http.HandleFunc("/gettoken", tokenHandler)

	fmt.Println("Serving on localhost:3000...")
	http.ListenAndServe(":3000", nil)

	// client := conf.Client(oauth2.NoContext, tok)
	// client.Get("...")
}
