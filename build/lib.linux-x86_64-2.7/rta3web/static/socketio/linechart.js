$(document).ready(function() {
    WEB_SOCKET_SWF_LOCATION = "/static/WebSocketMain.swf";
    WEB_SOCKET_DEBUG = true;

    // connect to the websocket
    var socket = io.connect('/chart');
    console.log("connected");

    $(window).bind("beforeunload", function() {
        socket.disconnect();
    });

    // Listen for the event "data" and add the content to the graph
    socket.on("data", function(e) {
        console.log("got a message");
        message = e;
        newMessage = true;
        reloadData('graph');
    });

});