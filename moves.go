package main

import (
	"encoding/json"
	"fmt"
	"github.com/joho/godotenv"
	"golang.org/x/oauth2"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
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
	fmt.Fprintf(w, "Moves Token: "+string(b))
}

func setTokenHandler(w http.ResponseWriter, r *http.Request) {
	log.Println(r.Method)
	if "POST" != r.Method {
		fmt.Fprintln(w, "GET not allowed.")
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	body, _ := ioutil.ReadAll(r.Body)
	log.Println("Received " + string(body))

	var parsed map[string]interface{}
	json.Unmarshal(body, &parsed)
	token = &oauth2.Token{
		AccessToken:  parsed["access_token"].(string),
		TokenType:    parsed["token_type"].(string),
		RefreshToken: parsed["refresh_token"].(string),
		Expiry:       parsed["expiry"].(time.Time),
	}
	log.Println(token)
	// for k, v := range r.Form {
	// log.Println("omg")
	// log.Println(k)
	// log.Println(v)
	// }
	// fmt.Fprintln(w, "Received " + string(body))
	// fmt.Fprintln(w, "Received " + token)
	// json.Unmar
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	key := os.Getenv("MOVES_KEY")
	secret := os.Getenv("MOVES_SECRET")
	fmt.Println("Moves Key: ", key)
	fmt.Println("Moves Secret: ", secret)

	config = &oauth2.Config{
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
	http.HandleFunc("/settoken", setTokenHandler)

	fmt.Println("Serving on localhost:3000...")
	http.ListenAndServe(":3000", nil)

	// client := conf.Client(oauth2.NoContext, tok)
	// client.Get("...")
}
