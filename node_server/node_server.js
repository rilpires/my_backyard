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
var room_by_connection = new Map()  // Map <connection,string>
connections_by_room.clear()
room_by_connection.clear()

let open_unique_id = 1000

ws_server.on("request",function(request){
    var connection = request.accept( null , request.origin )
    console.log("someone connected from: " , connection.remoteAddress )
    connection.sendUTF( "id:"+String(open_unique_id) )
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
            room_by_connection.set( connection , room_name )
            if( !connections_by_room.has(room_name) ){
                connections_by_room.set(room_name,[])
            }
            let connections_in_this_room = connections_by_room.get(room_name)
            connections_in_this_room.push(connection)
            let a = []
            console.log("Connected(total): " , room_by_connection.size )
            console.log("Connected("+room_name+"): " , connections_in_this_room.length )
        }

        // Else, it is player_state
        else {
            let room_name = room_by_connection.get(connection)
            if( room_name != undefined ){
                let connections_this_room = connections_by_room.get(room_name)
                for( let conn of connections_this_room ){
                    if( connection !== conn ){
                        conn.sendBytes( msg.binaryData )
                    } 
                }
            } else {
                console.log("Couldn't find a room for this connection...")
            }
        }
    })

    connection.on("close",function(code,desc){
        console.log("someone closed connection. code: " + code + " , desc: " + desc );
        let room_name = room_by_connection.get(connection)
        if( room_name != undefined ){
            let connections_in_this_room = connections_by_room.get(room_name)
            connections_in_this_room.map(function(value,index){
                if( value == connection ){
                    connections_in_this_room.splice( index+1 , 1 )
                }
            })
            room_by_connection.delete(connection)
            console.log("removed this person from rooms")
        }
    })


})