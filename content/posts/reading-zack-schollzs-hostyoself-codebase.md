---
title: Reading Zack Schollz's hostyoself codebase
tags:
  - go
  - deep dive
  - code read
  - websocket
date: 2020-05-14T17:56:46.301Z
draft: false
---
For the past few weeks  I've been practicing my code reading. So during my search for a Github Repo which i may find interesting enough to read, i stumbled upon a post on Reddit promoting [hostyoself](hostyoself.com). Hostyoself is a website which allows you to host flies from your machine online. I'm a web developer and i found this interesting as i had absolutely no idea how to implement something like this.

Luckily for me the entire source code for the project is available on Github so, Thank God!!

Here's what i found out after reading through the source code.

## Let's begin

Note: i put some of the code explanations as comments in the code

Upon startup of the CLI and running \`go run *.go h\` (opens help)

```
COMMANDS
  relay     start a relay
  host      host files from your computer
  help, h   shows a list of commands or help for one command
  
 relay OPTIONS:
   --url value, -u   value public url to use(default: "localhost")
   --port value      ports of the local relay (default: "8010")    
```

Going to hostyoself.com you're presented with this page(note i cropped out the top) and also running `go run *.go relay` runs the following code which starts the server.

```go
// --- file: main.go
// NOTE: some code deleted for brevity

func relay(c *cli.Context) (err error) {
    // line 6 - 13 are basically creating the url: http://localhost:8010
    // even if you give a different url it still uses the default
    flagPublicURL := c.String("url")
	if flagPublicURL == "localhost" {
		flagPublicURL += ":" + c.String("port")
	}
	if !strings.HasPrefix(flagPublicURL, "http") {
		flagPublicURL = "http://" + flagPublicURL
	}

    // start up the server
	s := server.New(flagPublicURL, c.String("port"))
	return s.Run()
}
```

The \`s.Run\` is what kicks off everything. In the background it runs the method below to serve files for specific routes

```go
// --- pkg/server/server.go
// NOTE: some code deleted for brevity

func (s *server) handle(w http.ResponseWriter, r *http.Request) (err error) {
	if r.URL.Path == "/robots.txt" {
        // serves robots.txt file used by search engines
		w.Write([]byte(`User-agent: * Disallow:`))
        
	} else if r.URL.Path == "/ws" {
        // starts the websocket on the route ws://localhost:8010/ws"
		return s.handleWebsocket(w, r)
        
	} else if strings.HasPrefix(r.URL.Path, "/static") {
		// serve static files (css, html, js, png)
        // NOTE: removed for brevity
        
        // serve homepage
	} else if r.URL.Path == "/" {
		var t *template.Template
		b, _ := Asset("templates/view.html")
		t, err = template.New("view").Parse(string(b))
		if err != nil {
			log.Error(err)
			return err
		}
		type view struct {
			PublicURL       template.JS
			GeneratedDomain string
			GeneratedKey    string
		}
		return t.Execute(w, view{
			PublicURL:       template.JS(s.publicURL),
			GeneratedDomain: namesgenerator.GetRandomName(),
			GeneratedKey:    utils.RandStringBytesMaskImpr(6),
		})

	} else {
        // main code responsible for actually putting the files up
        // keep reading for the explanation
    }
  }
```

Take note of line 33 and 34 those are generated words "domain" and "key" which can be seen in the page served at "/" which is what is pictured below.

![hostyoself homepage](/images/uploads/screencapture-localhost-8010-1589488130026.png)

Once the page is loaded the following Javascript code is run on the frontend

```javascript
var socket; // websocket
var files = [];
var isConnected = false;
var relativeDirectory = "";

const socketCloseListener = (event) => {
    if (socket) {
        consoleLog('[info] disconnected');
    }
    var url = window.origin.replace("http", "ws") + '/ws';
    try {
        socket = new WebSocket(url);
        socket.addEventListener('open', socketOpenListener);
        socket.addEventListener('message', socketMessageListener);
        socket.addEventListener('close', socketCloseListener);
    } catch (err) {
        consoleLog("[info] no connection available")
    }
}; 

// notice how this function call kicks off everything
// as it's implementation above opens the websocket and also
// allows listening on the socket
socketCloseListener();
```

The code aoove creates the websocket and starts listening to messages that may come through. This is done from line 9-12, notice the `socket.addEventListener('<event>', callback);`. I wont talk about websockets extensively here, i'll probably make another post about it someday.

From the code block above, there are events that run when a new websocket is opened, a message is sent or the websocket is closed.

The code that run when a new websocket is opened is this

```javascript
// --- static/main.js

const socketOpenListener = (event) => {
    consoleLog('[info] connected');
    
    // wont run because for now isConnected is actually false,
    // more on that later
    if (isConnected == true) {
        // reconnect if was connected and got disconnected
        socketSend({
            type: "domain",
            message: document.getElementById("inputDomain").value,
            key: document.getElementById("inputKey").value,
        })
    }
}
```

On line 7, The function doesn't run but it's purpose is to simply send data to the backend server which is handling the websocket connection created there. The data being sent is the domain and key which are automatically created on the backend and sent to the frontend rendered view.

Now what happens when you drop a file on the dropzone of the picture above the two separate code blocks above. Well, this is what happens.

On the frontend

```javascript
// --- static/main.js
// some code deleted for brevity

var files = [];
var isConnected = false;
var relativeDirectory = "";

// NOTE: this is using the dropzone.js library which allows for easy file
// uploads from file system to browser
drop.on('addedfile', function(file) {
    var domain = document.getElementById("inputDomain").value;
    files.push(file);
    
    // this is for chrome browsers only
    if ("webkitRelativePath" in file) {
        if (files.length == 1 && file.webkitRelativePath != "") {
            relativeDirectory = file.webkitRelativePath.split("/")[0];
        } else if (file.webkitRelativePath.split("/")[0] != relativeDirectory) {
            relativeDirectory = "";
        }
    }
    if ("fullPath" in file) {
        if (files.length == 1 && file.fullPath != "") {
            relativeDirectory = file.fullPath.split("/")[0];
        } else if (file.fullPath.split("/")[0] != relativeDirectory) {
            relativeDirectory = "";
        }
    }


    // isConnected at this point is false
    // so this code runs and sends the object in socketSend function to the
    // backend
    if (!(isConnected)) {
        isConnected = true;
        socketSend({
            type: "domain",
            message: domain,
            key: document.getElementById("inputKey").value,
        })
    }

    var filesString = "files are";
    var domainName = `${window.publicURL}/${domain}/`;
    if (files.length == 1) {
        filesString = "file is"
        domainName += `${file.name}`
    }

    document.getElementById("consoleHeader").innerHTML =
        `<p>Your ${filesString} available at:<br> <center><strong><a href="${domainName}" target="_blank">${domainName}</a></strong></center></p>`;
    html = `<ul>`
    for (i = 0; i < files.length; i++) {
        var urlToFile = files[i].name;
        if ('fullPath' in files[i]) {
            urlToFile = files[i].fullPath;
        }
        html = html +
            `<li><a href="/${domain}/${urlToFile}" target="_blank">/${urlToFile}</a></li>`
    }
    html = html + `</ul>`;
    document.getElementById("fileList").innerHTML = html;
    document.getElementById("filesBox").classList.add("hide");
    document.getElementById("console").classList.remove("hide");
    document.getElementById("inputKey").readOnly = "true";
    document.getElementById("inputDomain").readOnly = "true";
})
```

On the backend, this code runs

```go
// --- pkg/server/server.go

func (s *server) handleWebsocket(w http.ResponseWriter, r *http.Request) (err error) {
  // NOTE: some code deleted for brevity
  
  // receives whatever message is being sent to the route on the front end
  p, _ := ws.Receive()
  
  // check the data being received to see if it's correct
  if !(p.Type == "domain" && p.Message != "" && p.Key != "") {
      ws.Close()
      return nil
  }
  
  domain := strings.Replace(strings.ToLower(strings.TrimSpace(p.Message)), " ", "-", -1)
  
  // check if domain has already been saved, if it hasn't create it
  if _, ok := s.conn[domain]; !ok {
      s.conn[domain] = []*connection{}
  }
  
  // register the new connection in the domain
  s.conn[domain] = append(s.conn[domain], &connection{
      ID:     len(s.conn[domain]),
      Domain: domain,
      Joined: time.Now(),
      Key:    p.Key,
      ws:     ws,
  })
  log.Debugf("added: %+v", s.conn)
  s.Unlock()

  // send data back to the frontend
  err = ws.Send(wsconn.Payload{
      Type:    "domain",
      Message: domain,
      Success: true,
  })
  if err != nil {
      log.Error(err)
  }
}
```



And then you get a url with a random path like this:

![](/images/uploads/screencapture-localhost-8010-1589632056151.png)

Once you visit that URL, you see all the content which you put into the dropbox. But how does this happen?. Let's see

There is a block of code that watches all routes with this signature \`/*\`, why? Well that's because it's going to be to be the randomly generated domain and everyother route that has been predefined has already been handled here's the block of code which runs this.

```go
// --- pkg/server/server.go
// NOTE: some code deleted for brevity


// determine file path and the domain
pathToFile := r.URL.Path[1:]
domain := strings.Split(r.URL.Path[1:], "/")[0]

// clean domain
domain = strings.Replace(strings.ToLower(strings.TrimSpace(domain)), " ", "-", -1)

// prefix the domain if it doesn't exist
if !strings.HasPrefix(pathToFile, domain) {
    pathToFile = domain + "/" + pathToFile
    if filepath.Ext(pathToFile) == "" {
        pathToFile += "/"
    }
    http.Redirect(w, r, "/"+pathToFile, 302)
    return
}

// add slash if doesn't exist
if filepath.Ext(pathToFile) == "" && string(r.URL.Path[len(r.URL.Path)-1]) != "/" {
    http.Redirect(w, r, r.URL.Path+"/", 302)
    return
}

// trim prefix to get the path to file
pathToFile = strings.TrimPrefix(pathToFile, domain)
if len(pathToFile) == 0 || string(pathToFile[0]) == "/" {
    if len(pathToFile) <= 1 {
        pathToFile = "index.html"
    } else {
        pathToFile = pathToFile[1:]
    }
}
log.Debugf("pathToFile: %s", pathToFile)

// send GET request to websockets
var data string
var fs []File

// s.get is a function which goes through all the saved connections 
// and tries to get a connection to serve the files
// more on this later
data, err = s.get(domain, pathToFile, ipAddress)
if err != nil {
    // try index.html if it doesn't exist
    if filepath.Ext(pathToFile) == "" {
        if string(pathToFile[len(pathToFile)-1]) != "/" {
            pathToFile += "/"
        }
        pathToFile += "index.html"
        log.Debugf("trying 2nd try to get: %s", pathToFile)
        data, err = s.get(domain, pathToFile, ipAddress)
    }
    if err != nil {
        // try one more time
        if strings.HasSuffix(pathToFile, "/index.html") {
            pathToFile = strings.TrimSuffix(pathToFile, "/index.html")
            log.Debugf("trying 3rd try to get: %s", pathToFile)
            data, err = s.get(domain, pathToFile, ipAddress)
        }
        if err != nil {
            if pathToFile == "index.html" {
                // just serve files
                fs, err = s.getFiles(domain, ipAddress)
                log.Debugf("fs: %+v", fs)
                if err != nil {
                    log.Debug(err)
                    return
                }

                b, _ := Asset("templates/files.html")
                var t *template.Template
                t, err = template.New("files").Parse(string(b))
                if err != nil {
                    log.Error(err)
                    return
                }
                return t.Execute(w, struct {
                    Files  []File
                    Domain string
                }{
                    Domain: domain,
                    Files:  fs,
                })
            } else {
                log.Debugf("problem getting: %s", err.Error())
                err = fmt.Errorf("not found")
                return
            }
        }
    }
}

// decode the data URI
var dataURL *dataurl.DataURL
dataURL, err = dataurl.DecodeString(data)
if err != nil {
    log.Errorf("problem decoding '%s': %s", data, err.Error())
    return
}

// determine the content type
var contentType string
switch filepath.Ext(pathToFile) {
case ".css":
    contentType = "text/css"
case ".js":
    contentType = "text/javascript"
case ".html":
    contentType = "text/html"
}
if contentType == "" {
    contentType = dataURL.MediaType.ContentType()
    if contentType == "application/octet-stream" || contentType == "" {
        pathToFileExt := filepath.Ext(pathToFile)
        mimeType := filetype.GetType(pathToFileExt)
        contentType = mimeType.MIME.Value
    }
}
log.Debugf("%s/%s (%s)", domain, pathToFile, contentType)

// write the data to the requester
w.Header().Set("Content-Type", contentType)
w.Write(dataURL.Data)
return
```



So what happens on \`s.get\`

```go
// --- pkg/server/server.go

func (s *server) get(domain, filePath, ipAddress string) (payload string, err error) {
	var connections []*connection
	s.Lock()
    
    // check if domain has been saved
	if _, ok := s.conn[domain]; ok {
		connections = s.conn[domain]
	}
	s.Unlock()
	if connections == nil || len(connections) == 0 {
		err = fmt.Errorf("no connections available for domain %s", domain)
		log.Debug(err)
		return
	}

	// any connection that initated with this key is viable
	key := connections[0].Key

	// loop through connections randomly and try to get one to serve the file
    // this is possible because when the connection was created when the file
    // was being added in the frontend dropzone, the backend actually saved
    // a hashmap with the domain as the key and that connection as one of it's values
	for _, i := range rand.Perm(len(connections)) {
		var p wsconn.Payload
		p, err = func() (p wsconn.Payload, err error) {
            
            // when this runs it sends a message to the frontend javascript
            // code which will be listening and tries to make it serve the file
			err = connections[i].ws.Send(wsconn.Payload{
				Type:      "get",
				Message:   filePath,
				IPAddress: ipAddress,
			})
			if err != nil {
				return
			}
			p, err = connections[i].ws.Receive()
			return
		}()
		if err != nil {
			log.Debug(err)
			s.dumpConnection(domain, connections[i].ID)
			continue
		}
		log.Tracef("recv: %+v", p)
		if p.Type == "get" && p.Key == key {
			payload = p.Message
			if !p.Success {
				err = fmt.Errorf(payload)
			}
			return
		}
		log.Debugf("no good data from %d", i)
	}
	err = fmt.Errorf("invalid response")
	return
}
```

And that's the core of it.

Why the need for using the domain in the first place? Well see imagine he didn't use the domain strategy and this was being hosted online, if i send a file and you send a file, when we visit example.com/banjo we'll both be served the same file and that's bad for privacy you can imagine. So this strategy keeps things separate and private.



Thank You for reading. I know my writing has a long way to go, but if you have any comments please drop them in the comments below.