//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//  Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PostgreSQL


// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
        request, response in
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
        response.completed()
        let p = PGConnection()
        let status = p.connectdb("postgresql://dbuser:password@127.0.0.1:5432/exampledb")
        defer {
            p.close() // 关闭连接
        }
        let result = p.exec(
            statement: "
                CREATE TABLE films (code char(5) PRIMARY KEY, title varchar(40) NOT NULL)
            ")
        print("connect db")
    }
)
routes.add(method: .get, uri: "/test/", handler: {
        request, response in
        response.setHeader(.contentType, value: "application/json")
        let scoreArray: [String:Any] = ["第一名": 300, "第二名": 230.45, "第三名": 150]
        var encoded = ""
        do {
            encoded = try scoreArray.jsonEncodedString()
        } catch  {
            print("UserNotFound")
        }
        response.appendBody(string: encoded)
        response.completed()
    }
)

// Add the routes to the server.
server.addRoutes(routes)

server.serverAddress = "0.0.0.0"
// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
