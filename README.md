## irisrest
This is a REST API application in  ObjectScript using Docker container for InterSystems IRIS.
The repository includes files which let you immediately compile your ObjecScript files in InterSystems IRIS Community Edition in a docker container.

## Prerequisites
This needs to have git and docker installed.

## Installation 

Clone/git pull the repo into any local directory as shown below:

```
$ git clone https://github.com/oliverwilms/irisrest.git
```

Open the terminal in this directory and run:

```
cd irisrest
$ docker-compose build
```

or install it with ZPM client:
```
zpm:USER>install irisrest
```

Run the REST API application:

```
$ docker-compose up -d
```

## How to Work With it

I wanted to create an App to help me create my status report. I can create a new task, update an existing task, or delete a task. I can get information about a specific task or all tasks. These tasks are stored in persistent class App.Task.

## Swagger Specs

Use /_spec to see the Swagger Specs for this REST API:

```
localhost:52773/crud/task/_spec
```

# Testing GET requests

Even if there are no tasks stored yet, you can test the app with this request:

```
localhost:52773/crud/task/test
```

To get all tasks in JSON call:

```
localhost:52773/crud/task/all
```

To request the data for a particular record provide the id in GET request like 'localhost:52773/crud/task/id' . E.g.:

```
localhost:52773/crud/task/1
```

This will return JSON data for the task with ID=1, something like that:

```
{
    "TaskID": 1,
    "When": "2020-04-18T21:37:44Z",
    "What": "set up new document tracker class for client"
}
```

# Testing POST request

Create a POST request e.g. in Postman with raw data in JSON. e.g.

```
{ "What": "test document tracker class for client" }
```

Adjust the authorisation if needed - it is basic for container with default login and password for IRIS Community edition container

and send the POST request to localhost:52773/crud/task/newtask

This will create a record in Sample.Person class of IRIS.

# Testing PUT request

PUT request could be used to update a task. This needs to send the similar JSON as in POST request above supplying the id of the updated record in URL.
E.g. we want to change the record with id=2. Prepare in Postman the JSON in raw like following:

```
{ "what" : "populate document tracker class for client" }
```

and send the put request to:
```
localhost:52773/crud/task/2
```

# Testing DELETE request

For delete request this REST API expects only the id of the record to delete. E.g. if the id=2 the following DELETE call will delete the record:

```
localhost:52773/crud/task/2
```

## What's insde the repo

#FrontEnd Cache Server Page

If you are not really satisfied entering tasks in JSON format in Postman, you can try http://localhost:52773/csp/task/App.FrontEnd.cls

If you click on 'Test' button, it issues test request to REST api and displays a test message in JSON format. You may be asked to login the first time you access the REST api. Please use browser back button to go back.

# Dockerfile

The simplest dockerfile to start IRIS and load ObjectScript from /src/cls folder
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.

# Dockerfile-zpm

Dockerfile-zpm builds for you a container which contains ZPM package manager client so you are able to install packages from ZPM in this container
