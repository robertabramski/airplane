Airplane
--------

[![npm version](https://badge.fury.io/js/airplane.svg)](http://badge.fury.io/js/airplane)
[![dependencies](https://david-dm.org/jviotti/airplane.png)](https://david-dm.org/jviotti/airplane.png)
[![Build Status](https://travis-ci.org/jviotti/airplane.svg?branch=master)](https://travis-ci.org/jviotti/airplane)

![Airplane picture](https://raw.githubusercontent.com/jviotti/airplane/master/images/airplane.jpg)

Manage offline copies of your favourite websites for when you are on an airplane!

I used to manually keep track and update offline copies of software documentation for when I'm working on an airplane, but the method simply didn't scale for me once I was keeping track of quite a lot of websites.

Motivated by that, I created Airplane, an easy way to keep track of my offline sites, independently of how those offline copies were made.

I now hit `airplane` on the terminal the night after the trip, and I'm sure I'll have up to date offline copies of all the websites I need on the place.

Quickstart
----------

Create a basic `~/.airplanerc.json`:

```json
{
  "websites": {
    "lodash": "https://lodash.com",   
    "sinonjs": "http://sinonjs.org"
  },
  "options": {
    "destination": "/opt/www/airplane"
  },
  "commands": {
    "clone": "mkdir -p <%- destination %> && cd <%- destination %> && httrack <%- url %>",
    "update": "cd <%- destination %> && httrack --update <%- url %>"
  }
}
```

In this case, I'm keeping track of [lodash](https://lodash.com) and [sinonjs](http://sinonjs.org).

I set my `destination` option to `/opt/www/airplane`. I have a web server configured to serve that directory locally.

I like to use [httrack](http://www.httrack.com) to clone my websites, so I configured my `clone` and `update` commands accordingly. You can use any tool you like.

Typing `airplane` in my terminal brings the fun:

![Airplane in action](https://raw.githubusercontent.com/jviotti/airplane/master/images/screenshot.png)

I can now open `http://localhost/lodash` or `http://localhost/sinonjs` to access the websites offline.


Installation
------------

Install `airplane` by running:

```sh
$ npm install -g airplane
```

Documentation
-------------

### ~/.airplanerc.json

The configuration file containing the sites you want to manage, and a few options.

#### websites

An object containins websites to clone. Keys are the names, and values are the urls:

```json
...
"websites": {
  "lodash": "https://lodash.com",   
  "sinonjs": "http://sinonjs.org"
},
...
```

#### options.destination

The destination directory in which to clone the specified websites.

Is recommended that you setup a web server to locally serve that directory.

```json
...
"options": {
  "destination": "/opt/www/airplane"
},
...
```

#### commands.clone

The command to use to clone a website. It uses [UnderscoreJS templates syntax](http://underscorejs.org/#template) to interpolate:

- `destination`: The final destination of the website. This is the concatenation between `options.destination` and the website name.
- `url`: The url of the website.
- `name`: The selected name for the website.

I like to use [httrack](http://www.httrack.com), but you can use any other software to clone the website.

```json
...
"commands": {
  "clone": "mkdir -p <%- destination %> && cd <%- destination %> && httrack <%- url %>",
}
...
```

#### commands.update

Same as `commands.clone`, but the update command is triggered when the website was already cloned in the past.

```json
...
"commands": {
  "update": "cd <%- destination %> && httrack --update <%- url %>"  
}
...
```

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/jviotti/airplane/issues](https://github.com/jviotti/airplane/issues)
- Source Code: [github.com/jviotti/airplane](https://github.com/jviotti/airplane)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/jviotti/airplane/issues/new) on GitHub.

License
-------

The project is licensed under the MIT license.

Front illustration taken from [freedigitalphotos.net](http://www.freedigitalphotos.net).
