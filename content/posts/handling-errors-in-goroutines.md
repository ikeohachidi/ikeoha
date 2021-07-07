---
title: Handling errors in Goroutines
tags:
  - go
  - concurrency
date: 2020-06-21T20:43:40.858Z
draft: false
---
While working on the server for my side project [fontkit](https://github.com/ikeohachidi/fontkit-server) i wanted to retrieve data from the database concurrently. This seems like a trivial thing to do in go with goroutines but the problem was i needed to handle errors too.
So this is what i came up with

NOTE: parts of original code cut for brevity.

```go
db, err := sql.Open()
if err !=  nil {
	log.Print(err)
}

func QueryDatabase(son string) (Family, error) {
	var wg sync.WaitGroup
	var family Family

	// errChan will receive an error and once it does it returns it on the function
	errChan :=  make(chan  error)
	// sends a signal that the goroutines are done so the function can return
	done :=  make(chan  bool)
	// NOTE: See bottom of code for select statement using errChan and done

	wg.Add(1)
	go  func(wg *sync.WaitGroup) {
		defer wg.Done()

		query := fmt.Sprintf("SELECT father, mother FROM family WHERE son='%v'", son)
		stmt, err := db.Prepare(query)
		if err !=  nil {
			errChan <- err
			return
		}
	
		stmt, err := db.Prepare(query)
		if err !=  nil {
			errChan <- err
			return
		}

		row := stmt.QueryRow()
		if err = row.Scan(&family.father, &family.mother); err !=  nil {
			if err == sql.ErrNoRows {
				return
			}
			errChan <- err
			return
		}
	}(&wg)

  

	wg.Add(1)
	go  func(wg *sync.WaitGroup) {
		defer wg.Done()

		query := fmt.Sprintf("SELECT uncle, aunty FROM extended_family WHERE nephew='%v'", son)

		stmt, err := db.Prepare(query)
		if err !=  nil {
			errChan <- err
			return
		}
	
		stmt, err := db.Prepare(query)
		if err !=  nil {
			errChan <- err
			return
		}
	
		row := stmt.QueryRow()
		if err = row.Scan(&family.uncle, &family.aunt); err !=  nil {
			if err == sql.ErrNoRows {
				return
			}
			errChan <- err
			return
		}
	}(&wg)

	// this goroutine is created so the waitgroup doesn't block the execution of the select statement to wait for errors
	go  func(wg *sync.WaitGroup) {
		wg.Wait()
		close(done)
	}(&wg)

	select {
		case  <-done:
		return coll, nil
	case err :=  <-errChan:
		return coll, err
	}

}
```

You probably noticed the return statements after the send to a channel like this:

```go
errChan <- err
return
```

This is because the code `defer wg.Done()` runs when a function has finished execution and returns. Without the `return` statement after the send to a channel i could be working with a nil value and that isn't good.

If you have anything to add, please comment below