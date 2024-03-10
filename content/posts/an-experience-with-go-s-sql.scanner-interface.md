---
tags:
- go
- " sql"
title: An experience with Go's sql.Scanner interface
description: Disturbance comes only from within, from our own perceptions
date: 2021-09-05T23:00:00Z
draft: false

---
During development of an application I've been working on (Chapi). This app like almost every other app on earth uses a database, PostgreSQL to be exact.

My experience came when i need to make a database query to give me that values for a struct.

    type Route struct {
    	ID          uint           `json:"id" db:"id"`
    	ProjectID   uint           `json:"projectId" db:"project_id"`
    	UserID      uint           `json:"userId" db:"user_id"`
    	Type        string         `json:"type" db:"type"`
    	Path        string         `json:"path" db:"path"`
    	Destination string         `json:"destination" db:"destination"`
    	Body        sql.NullString `json:"body" db:"body"`
    	CreatedAt   time.Time      `json:"createdAt" db:"created_at"`
    	Queries     Query[]        `json:"queries" db:"queries"`
    }

An sql `JOIN` is a very sane way to accomplish this.

    SELECT 
        route.id, route.project_id, route.path, route.destination,
        "query".id, "query"."name", "query"."value"
    FROM route
    INNER JOIN "query" on route.id = "query"."route_id"

So using the `JOIN` i got the result (**NOTE: some columns of result reduced for brevity**):

![](/screenshot-from-2021-09-05-12-01-47.png)

If i used a library like GORM it would actually automatically marshal the values properly. But see i didn't want to use GORM because beside this being a passion project it is also a learning experience for me. So i decided not to use any ORM and write as much SQL as needed.

Using Go's normal SQL `Row.Scan` method wasn't working. The problem was marshaling the query part( last id, name and value) needed to be inside the `Route.Queries` slice.

The only way i could think of to achieve this with the present result would be a loop, not bad but i didn't want that.

After some digging around i found `sql.Scanner` interface, which gives the ability to express how results are scanned. But for me to use it some changes needed to be made:

1. Return a `queries` column from the db (new query)
2. Create a `Queries` type, which is basically an array of `Query`
3. Implement the `sql.Scanner` interface for the custom `Queries` type

**STEP 1**

After digging around the internet and PostgreSQL docs i was able to write a sensible query

    SELECT
    	route.*,
    	array_agg(json_build_object('id', "query".id, 'name', "query"."name", 'value', "query"."value")) as queries
    FROM route
    INNER JOIN "query" ON route.id = "query".route_id
    WHERE route.project_id = (
    		SELECT id FROM project WHERE "name" = $1
    	)
    AND path = $2
    GROUP BY route.id

The query returns this:

![](/screenshot-from-2021-09-05-12-31-16.png)

Notice the `queries` column now returns an array array of json objects. That's what line 2 does `json_build_object` creates a json object and `array_agg` is an aggregate function to put them all in an array... mad!!!

**STEP 2 & 3** 😁

Create the custom `Query` type

    type Queries Query[]

Line 10 of the `Route` struct will change to:

    Queries Queries `json:"queries" db:"queries"`

Now to implement it's `sql.Scanner` interface

    func (qu *Queries) Scan(src interface{}) (err error) {
    	buf := bytes.NewBuffer(src.([]uint8))
    
    	trimmed := bytes.TrimPrefix(buf.Bytes(), []byte("{\""))
    	trimmed = bytes.TrimSuffix(trimmed, []byte("\"}"))
    
    	queries := bytes.Split(trimmed, []byte("\",\""))
    
    	for _, query := range queries {
    		var q Query
    
    		cleanedJSON := bytes.ReplaceAll(query, []byte("\\"), []byte(""))
    
    		err = json.Unmarshal(cleanedJSON, &q)
    		if err != nil {
    			return
    		}
    
    		*qu = append(*qu, q)
    	}
    
    	return nil
    }

And just like that now i could run `Row.Scan` method with no hassle.
