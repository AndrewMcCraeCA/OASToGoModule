
# OpenAPI Spec to Go Module
In this project, we will demonstrate the process of transforming an OpenAPI specification file into a Go module containing client code for the given API.
Then we will publish this Go module.

### Why would you want to generate the code ?
* To save time and effort vs writing from scratch.
* Consistency and accuracy, ~~so you can blame any errors on the documentation rather than your coding.~~ manually writing code can lead to mistakes in your code or inconsistencies between your code and the API.
* When new versions of the API are released you can simply regenerate the client code reducing maintenance. 

---

## Prerequisites

Before you begin, make sure you have the following tools and software installed:

- [Go - v1.18 or later](https://go.dev/)
- [openapi-generator - v7.0.0 or later](https://openapi-generator.tech/)

If you haven't installed these tools yet, please follow the links to installation instructions below.

### Installation

#### Go

Please download and install golang from https://go.dev/doc/install.

Ensure you have a version greater than 1.18.

Check it is sucessfully installed by running `go version`, you should get something like: 

```
go version
go version go1.21.1 darwin/amd64
```


#### Openapi-generator

Please install the latest version via homebrew: 

```
brew install openapi-generator
```

Check it has sucessfully installed by running `openapi-generator version`, you should get something like:

```
openapi-generator version
7.0.0
```

Full instructions can be found here https://openapi-generator.tech/docs/installation#homebrew 

---

## Instructions


This project is divided into several steps, each with its own set of actions and instructions. 
Follow the steps below to progress through the session:

### Step 1: Choose your API-dventure

For this session we want to work from an OpenAPI specification file for an existing HTTP API.

#### What is OpenAPI?
The OpenAPI specification, formerly known as Swagger, is a set of rules and conventions for defining and describing RESTful APIs (Application Programming Interfaces) in a standardized and machine-readable format. 
It serves as a way to document and communicate the functionality, structure, and behavior of an API, making it easier for developers to understand and interact with the API.

More information on the OpenAPI Specification can be found [here](https://swagger.io/specification/).

#### Choose a OpenAPI spec file
For the purpose of this session we want to work from a spec file of a simple API to demonstrate the process of generating golang client code.

Ensure you have the spec file downloaded locally and that you know the filepath to its location.

A handful of example spec files for some public APIs are provided in the [examples](./examples) folder.

If you prefer to use a different spec of your own choosing feel free to, just make sure you have the spec YAML or JSON file downloaded locally. 
Some recommendations to consider when choosing your example API:
* The OpenAPI spec is available to download.... cause like you need the spec file.
* The API/service is public and is not a private internal service.
  1. To make it easy to test when we send requests to it.
  2. In a later step we will publish the code as a Go module publicly. We probably do not want a public module describing the API for services on GitHub.
* Authentication is either not required or is simple like username/password or uses an access token/apikey(that you already have).
* The API has some easy to fairly simple GET requests that you can wrap your head around.


### Step 2: Generate the module

Now we have our API spec file, we want to generate the client code for it.

To do this we will use the openapi-generator CLI tool. Other tools are available such as Swagger Codegen, AutoRest and NSwag, feel free to explore these in future but for this session we will use openapi-generator.

#### What is openapi-generator?
OpenAPI-generator a widely-used, open-source tool that supports a wide range of programming languages. It can generate client libraries, server stubs, API documentation, and more from OpenAPI specifications.

This tool can create code for many different languages. It is open source so developers can add new generators for languages not currently supported.


More information can be found on their [website](https://openapi-generator.tech/) and the generator [github repository](https://github.com/OpenAPITools/openapi-generator).

Sometimes these generators do not support some features of a given language/HTTP API and/or certain features of the OpenAPI spec. So it does pay to check out the generator you want to use and ensure it will support your OpenAPI spec and the features of the API. 

For example the [Go generator](https://openapi-generator.tech/docs/generators/go/) does not support the OAS 3 feature of `anyOf` which is used to define things like when their are multiple options for response body types. And it also does not support OpenID connect Authorization on the HTTP requests.

#### Running the generate command

The CLI tool has a bunch of different commands and takes a bunch of different config flags and arguments. We can list these out by doing a `openapi-generator help` this shows us all the different commands available.

Now we will run the `openapi-generator generate` command to create our go module.

We can look at the generate command more specifically `openapi-generator generate help` to see the full set of required and optional flags.

I've tried to simplify this by creating a script file [scripts/generateClient.sh](./scripts/generateClient.sh) that takes 3 parameters to cover all the required flags and some optional ones.  Let's look at the contents of the script to see what we are actually about to do.

```
# the arguments to the script

openAPI_file_path=$1 #Path to openapi file
github_username=$2 #Your github username
module_name=$3 #New go module name
```

and here is the generate command and the arguments we want to pass in:
```

#  openapi-generator-cli generate - Generate code with the specified generator.
# -g <generator name>, --generator-name <generator name> \ generator to use (see list command for list)

# --git-repo-id <git repo id> \ Git repo ID, e.g. openapi-generator.
# --git-user-id <git user id> \Git user ID, e.g. openapitools.

# -i <spec file>, --input-spec <spec file> \ location of the OpenAPI spec, as URL or file (required if not loaded via config using -c)
# -o <output directory>, --output <output directory> \ where to write the generated files (current dir by default)

# --package-name <package name> \ package for generated classes (where supported)

openapi-generator generate \
  -g go \
  --git-repo-id $module_name \
  --git-user-id $github_username -i $openAPI_file_path \
  -o $module_name \
  --package-name $module_name
  
```

So now lets run the script: 

`./scripts/generateClient.sh examples/acmi.json AndrewMcCraeCA goacmi`

You should see something like:

`Created new Go module: github.com/AndrewMcCraeCA/goacmi in folder /Users/andrew.mccrae/code/github/AndrewMcCraeCA/OASToGoModule/goacmi`

That's it, we now have a full go module providing us an API client, with tests and documentation as well!

It is recommended to confirm the module is all working ok. We can do this by runnning go mod and go test

```
go mod tidy && go test ./...
```

### Step 3: Trying it locally

Now we have our Go module maybe we should try it out.

#### Copying the example Go code.

If you open your new go module and open the README file, it will have a full set of instructions on how to use the module.

But we can skip down to the "Documentation for API Endpoints" section, there should be table of available endpoints.

Open the documentation for a simple GET request if there is one and copy the example code.

it should look something like this:

```go
package main

import (
    "context"
    "fmt"
    "os"
    openapiclient "github.com/AndrewMcCraeCA/goacmi"
)

func main() {

    configuration := openapiclient.NewConfiguration()
    apiClient := openapiclient.NewAPIClient(configuration)
    resp, r, err := apiClient.DefaultAPI.RootGet(context.Background()).Execute()
    if err != nil {
        fmt.Fprintf(os.Stderr, "Error when calling `DefaultAPI.RootGet``: %v\n", err)
        fmt.Fprintf(os.Stderr, "Full HTTP response: %v\n", r)
    }
    // response from `RootGet`: Get200Response
    fmt.Fprintf(os.Stdout, "Response from `DefaultAPI.RootGet`: %v\n", resp)
}
```

Returning to the project repo we can paste this code over the empty [main.go](./main.go) file.

Edit the example to ensure you have added any required fields like API keys or parameters.

Then we should be ready to roll. However! since this newly created module is not public we need to point to our local version for now.

#### Modifying our go.mod file

Open the go.mod file in our project repo. There should be a line with the following comment:

```
//replace github.com/<your-github-name-here>/<your-go-module-name-here> v0.0.0 => ./<your-go-module-name-here>
```

Update this with your github username and name of the new module and uncomment the line. It should look something like this:

```
replace github.com/AndrewMcCraeCA/goacmi v0.0.0 => ./goacmi
```

Now in the terminal make sure you are in the `OASToGoModule` directory and run:

`go mod tidy`

You should see something like:

`go: found github.com/AndrewMcCraeCA/goacmi in github.com/AndrewMcCraeCA/goacmi v0.0.0`

#### Now lets run it

Now in the terminal enter:

`go run main.go`

This should then use our new module to hit the API! You should see something like: 

```
Response from `DefaultAPI.RootGet`: &{0xc0001aa140 [/constellations/ /constellations/<constellation_id>/ /creators/ /creators/<creator_id>/ /search/ /works/ /works/<work_id>/] 0xc0001aa160}
```

Remember that the client code has created a series of structs for the response object and it's fields. Sometimes these will be pointers and you may need to dereference them just now to see the values.
