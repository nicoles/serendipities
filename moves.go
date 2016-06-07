package main

import (
  "golang.org/x/oauth2"
  "fmt"
  "os"
  // "io/ioutil"
  // "flag"
  "html/template"
  "net/http"
  // "log"
)

var movesAuthURL string = ""

func check(err error) {
  if nil != err {
    panic(err)
  }
}

/*
func loadPage(title string) (*Page, error) {
    filename := title + ".txt"
    body, err := ioutil.ReadFile(filename)
    if err != nil {
        return nil, err
    }
    return &Page{Title: title, Body: body}, nil
}
*/

func handler(w http.ResponseWriter, r *http.Request) {
  // fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
  // fmt.Fprintf(w, movesAuthUrl)
  data := struct{
    MovesURL string
  }{
    movesAuthURL,
  }
  fmt.Println(data)
  t, _ := template.ParseFiles("index.html")
  t.Execute(w, data)
}

// Callback once moves has authorized.
func authHandler(w http.ResponseWriter, r *http.Request) {
  params := r.URL.Query()
  codes, ok := params["code"]
  if !ok || nil == codes {
    w.WriteHeader(http.StatusBadRequest)
    return
  }
  state, ok := params["state"]
  if !ok || nil == state {
    fmt.Fprintf(w, "Invalid State")
    w.WriteHeader(http.StatusBadRequest)
    return
  }
  code := codes[0]
  fmt.Fprintf(w, "Auth Code:  " + code)
}

func main() {

  // key := flag.String("moves_key", "", "Moves Key")
  // secret := flag.String("moves_secret", "", "MovesSecret")
  // flag.Parse()
  // getParams()
  key := os.Getenv("MOVES_KEY")
  secret := os.Getenv("MOVES_SECRET")
  fmt.Println("Moves Key: ", key)
  fmt.Println("Moves Secret: ", secret)

  conf := &oauth2.Config{
    ClientID:     key,
    ClientSecret: secret,
    Scopes: []string{"activity location"},
    Endpoint: oauth2.Endpoint{
      AuthURL:  "",
      TokenURL: "",
    },
  }
  fmt.Println("conf:", conf)

  moves_url := "https://api.moves-app.com/oauth/v1/authorize"

  // url := conf.AuthCodeURL("state", oauth2.AccessTypeOffline)
  url := moves_url + conf.AuthCodeURL("state")
  movesAuthURL = url

  fmt.Println("\nMoves API URL: ", url)

  http.HandleFunc("/", handler)
  http.HandleFunc("/auth/moves/callback", authHandler)

  fmt.Println("Serving on localhost:3000...")
  http.ListenAndServe(":3000", nil)

  // Use the authorization code that is pushed to the redirect URL.
  // NewTransportWithCode will do the handshake to retrieve
  // an access token and initiate a Transport that is
  // authorized and authenticated by the retrieved token.
  /*
  var code string
  if _, err := fmt.Scan(&code); err != nil {
      log.Fatal(err)
  }
  tok, err := conf.Exchange(oauth2.NoContext, code)
  if err != nil {
      log.Fatal(err)
  }
  
  client := conf.Client(oauth2.NoContext, tok)
  client.Get("...")
  */
}
