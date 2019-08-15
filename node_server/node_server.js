var WebSocketServer = require('websocket').server;
var http = require('http')

var http_server = http.createServer( function(request,response){
    // We are only implementing websocket here
})

http_server.listen( 4123 )

var ws_server = new WebSocketServer({
    httpServer : http_server ,
})


var connections_by_room = new Map() // Map <string,connection array>
var all_connections = new Map() // Map<id,connection>
connections_by_room.clear()

let open_unique_id = 1000

ws_server.on("request",function(request){
    var connection = request.accept( null , request.origin )
    console.log("someone connected from: " , connection.remoteAddress , " , server_id: " , open_unique_id )
    connection.sendUTF( "id:"+String(open_unique_id) )
    connection.server_id = open_unique_id
    connection.room = undefined
    all_connections.set( connection.server_id , connection )
    open_unique_id++

    connection.on("message",function( msg ){

        if( msg.type == "utf8" ){
            // console.log("Message received, type: utf8 , size: " , msg.utf8Data.length )
            // console.log( msg.utf8Data  )
        }
        else{
            // console.log("Message received, type: binary, size: " , msg.binaryData.length )
        }
        
        // If Text message, it is room's name
        if( msg.type == "utf8" ){
            let room_name = msg.utf8Data
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
                        conn.sendBytes( msg.binaryData )
                    }
                })
            } else {
                console.log("Couldn't find a room for this connection...")
            }
        }
    })

    connection.on("close",function(code,desc){
        console.log("someone closed connection. code: " + code + " , desc: " + desc );
        let room_name = connection.room
        if( room_name ){
            let connections_in_this_room = connections_by_room.get(room_name)
            connections_in_this_room.delete( connection.server_id )
            connections_in_this_room.forEach(function(conn,index,array){
                conn.sendUTF( "dc:"+connection.server_id )
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
            value.sendUTF( "rooms:" + packet )
        }
    })

} , 900 )