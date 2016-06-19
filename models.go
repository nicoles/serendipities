//http://jinzhu.me/gorm/models.html#model-definition
package main

import (
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/sqlite"
  "time"
)

type User struct {
  gorm.Model
  // Storylines []Storyline
  Authentications []Authentication
  IsAdmin bool
}

type Authentication struct {
  gorm.Model
  Service string
  UserID int `gorm:"index"`
  Token string
  RefreshToken string
  ExpiresAt time.Time
  CreatedAt time.Time
  UpdatedAt time.Time
  UID string
}

/*
type Storyline struct {
  gorm.Model
  Moments []Moment
}

type Moment struct {
  gorm.Model

  StartTime
  EndTime
  Activities []Activity
  SegmentID
  SegmentType // either move or place
}

type Move struct {
  gorm.Model

  Moment Moment `gorm:"polymorphic:Segment;"`
}

type Stop struct {
  gorm.Model

  Place Place
  Moment Moment `gorm:"polymorphic:Segment;"`
}

type Place struct {
  gorm.Model

  MovesID int
  Name
  Type string
  TypeID string
  Latitude
  Longitude
}

type Activity struct {
  gorm.Model

  Type string
  StartTime
  EndTime
  Calories
  Distance
  Duration
  Geometry
}
*/
