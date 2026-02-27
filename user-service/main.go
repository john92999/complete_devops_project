package main

import (
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"

    _ "github.com/go-sql-driver/mysql"
)

var db *sql.DB

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func initDB() {
    dsn := os.Getenv("DB_DSN") // user:pass@tcp(host:3306)/dbname
    var err error
    db, err = sql.Open("mysql", dsn)
    if err != nil {
        log.Fatal(err)
    }
    db.Exec(`CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100)
    )`)
}

func getUsers(w http.ResponseWriter, r *http.Request) {
    rows, _ := db.Query("SELECT id, name, email FROM users")
    defer rows.Close()
    var users []User
    for rows.Next() {
        var u User
        rows.Scan(&u.ID, &u.Name, &u.Email)
        users = append(users, u)
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

func createUser(w http.ResponseWriter, r *http.Request) {
    var u User
    json.NewDecoder(r.Body).Decode(&u)
    res, _ := db.Exec("INSERT INTO users (name, email) VALUES (?, ?)", u.Name, u.Email)
    id, _ := res.LastInsertId()
    u.ID = int(id)
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(u)
}

func main() {
    initDB()
    http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
        if r.Method == "GET" {
            getUsers(w, r)
        } else if r.Method == "POST" {
            createUser(w, r)
        }
    })
    fmt.Println("User service on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}