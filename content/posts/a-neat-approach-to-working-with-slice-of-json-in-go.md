---
tags:
- go
- sql
title: A neat approach to working with slice of json in Go
description: I don't have to turn this into something, It doesn't have to upset me.
date: 2021-11-05T23:00:00Z
draft: false

---
I was considering simply updating my previous post on this subject, but ultimately decided not to. There can be multiple ways to approach something and it's important to note progress.

The previous post about a topic that kind of concerned this was [https://ikeoha.com/post/an-experience-with-go-s-sql.scanner-interface](https://ikeoha.com/post/an-experience-with-go-s-sql.scanner-interface "Working with sql.scanner") The approach there works but requires a lot of code. As i kept with SQL on my project chapi i soon found a better approach.

This approach uses a simple PostgreSQL function `array_to_json(array)`. Which returns an array of json.

Using in a select statement

```Go
	SELECT *,
    	array_to_json(array_agg(<column>.*)) as <alias>
    FROM <table>
```

So you can simply implement your `sql.scanner` interface now
E.g

```Go
type People Person[]

func(pe *Person) Scan(src interface{}) (err error) {
	buf := bytes.NewBuffer(src.([]byte))

	err = json.Unmarshal(buf.Bytes(), &qu)
	if err != nil {
		return
	}

	return nil
}
```

If you find any issues with what i've written email me @ ikeohachidi@gmail.com