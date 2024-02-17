const APP_PORT = process.env.APP_PORT || 8000
var express = require("express")
var app = express()
var WebSocket = require('ws').WebSocketServer;
var http = require('http')


var connections_by_room = new Map() // Map <string,connection array>
var all_connections = new Map() // Map<id,connection>
connections_by_room.clear()

app.use(  express.static("dist") )

var http_server = http.createServer( {'http1.1':true}, app )

let ws_server = new WebSocket({ server: http_server})


http_server.on("connection",function(socket){
    let address = socket.address()
    console.log("HTTP: Someone is trying to reach from: " , address.address +":"+ address.port )
})

let open_unique_id = 1000

http_server.on("upgrade",function(request,socket,head){
    console.log("Someone is trying to upgrade the connection..."
        , request.headers.origin
        , request.headers.host
        , request.headers.upgrade
        , request.headers.connection
    );
});

ws_server.on("connection", function(connection){
    console.log(connection)
    connection.send( "id:"+String(open_unique_id) )
    connection.server_id = open_unique_id
    connection.room = undefined
    all_connections.set( connection.server_id , connection )
    open_unique_id++

    connection.on("message",function( msg ){
        const isUtf8 = msg[0] != 18;
        if( isUtf8 ){
            // console.log("Message received, type: utf8 , size: " , msg.utf8Data.length )
            // console.log( msg.utf8Data  )
        }
        else{
            // console.log("Message received, type: binary, size: " , msg.binaryData.length )
        }
        
        // If Text message, it is room's name
        if( isUtf8 ){
            let room_name = String(msg)
            connection.room = room_name
            if( !connections_by_room.has(room_name) ){
                connections_by_room.set(room_name, new Map() )
            }
            let connections_in_this_room = connections_by_room.get(room_name)
            connections_in_this_room.set( connection.server_id , connection )
            console.log("Connected(total): " , all_connections.size )
            console.log("Connected("+room_name+"): " , connections_in_this_room.size )
        }

        // Else, it is player_state
        else {
            let room_name = connection.room
            if( room_name ){
                let connections_this_room = connections_by_room.get(room_name)
                connections_this_room.forEach( function(conn, conn_id ,map){
                    if( conn.server_id != connection.server_id ){
                        conn.send( msg )
                    }
                })
            } else {
                console.log("Couldn't find a room for this connection...")
            }
        }
    })

    connection.on("close",function(code,desc){
        console.log("Someone closed connection. code: " + code + " , desc: " + desc );
        let room_name = connection.room
        if( room_name ){
            let connections_in_this_room = connections_by_room.get(room_name)
            connections_in_this_room.delete( connection.server_id )
            connections_in_this_room.forEach(function(conn,index,array){
                conn.send( "dc:"+connection.server_id )
            })
            console.log("and was kicked off from " , room_name )
        }
        all_connections.delete(connection.server_id)
    })


})

// Periodically sends information about created rooms
setInterval( function(){
    connections_by_room.forEach(function(value,key,map){
        if(value.size==0){
            console.log("Room " + key + " is empty. Deleting it...")
            connections_by_room.delete(key)
        }
    })
    
    let packet = {}
    connections_by_room.forEach(function(value,key,map){
        packet[key] = value.size
    })
    
    packet = JSON.stringify(packet)
    
    all_connections.forEach(function(value,key,map){
        if( value.room === undefined ){
            value.send( "rooms:" + packet )
        }
    })

} , 900 )

http_server.listen( APP_PORT , function(){
    console.log("Server is listening on port: " , APP_PORT )
});