package main

import (
	"encoding/json"
	"fmt"
	"github.com/joho/godotenv"
	"html/template"
	"log"
	"net/http"
	"os"
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/postgres"
)

var moves *MovesAPI

func indexHandler(w http.ResponseWriter, r *http.Request) {
	url := moves.GetAuthURL()
	fmt.Println("\nUsing Moves API URL: \n", url)

	data := IndexData{url, moves.Token}
	fmt.Println(data)

	t, _ := template.ParseFiles("templates/index.html")
	t.Execute(w, data)
}

// Callback once Moves has authorized.
func authHandler(w http.ResponseWriter, r *http.Request) {
	if nil != moves.Token {
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
	moves.AuthCode = r.FormValue("code")
  // Must redirect so Moves doesn't cause incorrectly duplicated callback.
	http.Redirect(w, r, "/gettoken", 301)
}

// Expected to be requested only as part of redirect from authHandler.
// Exchanges auth code for actual token.
func getTokenHandler(w http.ResponseWriter, r *http.Request) {
	err := moves.GetToken()
	if nil != err {
		fmt.Fprintf(w, "Problem getting token.\n")
		fmt.Fprintf(w, err.Error())
		log.Println(w, err.Error())
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	// Also output the token!
	b, _ := json.Marshal(moves.Token)
	fmt.Fprintln(w, "Congratulations, you've authed with MovesAPI.")
	fmt.Fprintf(w, "Moves Token: "+string(b))
}

/*
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
	moves.Token = &oauth2.Token{
		AccessToken:  parsed["access_token"].(string),
		TokenType:    parsed["token_type"].(string),
		RefreshToken: parsed["refresh_token"].(string),
		Expiry:       parsed["expiry"].(time.Time),
	}
	log.Println(token)
}
*/

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	key := os.Getenv("MOVES_KEY")
	secret := os.Getenv("MOVES_SECRET")
	moves = NewMovesAPI(key, secret)

  dbname := os.Getenv("DATABASE_NAME")
  dbuser := os.Getenv("DATABASE_USER")

  db, err := gorm.Open("postgres", "user="+dbuser+" dbname="+dbname+" sslmode=disable")
  if err != nil {
    panic(err)
    return
  }

  db.AutoMigrate(&User{})

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/auth/moves/callback", authHandler)
	http.HandleFunc("/gettoken", getTokenHandler)
	// http.HandleFunc("/settoken", setTokenHandler)

	fmt.Println("Serving on localhost:3000...")
	http.ListenAndServe(":3000", nil)
}
