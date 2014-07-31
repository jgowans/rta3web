var socket = null
$(document).ready(function() {
    WEB_SOCKET_SWF_LOCATION = "/static/WebSocketMain.swf";
    WEB_SOCKET_DEBUG = true;

    // connect to the websocket
    socket = io.connect('/waterfall');
    console.log("connected");

    $(window).bind("beforeunload", function() {
        socket.disconnect();
    });

    // Listen for the event "data" and add the content to the graph
    socket.on("data", function(m) {
        newMessage = true;
        pjs.setLabels(m["heading"], m["xaxis"], m["yaxis"]);
        console.log(m);
        console.log("minY = " + m["minY"]);
        console.log("typeof m[minY] " + typeof m["minY"]);
        pjs.setRFIMask(eval(m['mask']));
        pjs.setValues(m["minX"], m["maxX"], m["minY"], m["maxY"], m["maxA"], m["minA"], m["nX"], m["nY"], m["minPosX"], m["maxPosX"], m["minPosY"], m["maxPosY"], eval(m["data"]));
        console.log("recieved message");
        // console.log(m["minX"]);
        // console.log(m["maxX"]);
        // console.log(m["minY"]);
        // console.log(m["maxY"]);
    });
   
    
});

function zoom(startT, endT, lowChan, highChan){
    console.log("sending zoom packet");
    socket.emit('zoom', {"startT":startT,
                        "endT":endT,
                        "lowChan":lowChan,
                        "highChan":highChan});
}

function displayWaterfall(id, heading, xaxis, yaxis, minX, maxX, minY, maxY, maxA, minA, nX, nY, miPX, maPX, miPY, maPy, data) {
    console.log("in method");
    console.log (" minY = " + minY + " maxY = " + maxY);
    console.log (" minX = " + minX + " maxX = " + maxX);
    pjs = Processing.getInstanceById(id);
    if (pjs != null){
        pjs.setDVals(minX, maxX, minY, maxY);
        pjs.setLabels(heading, xaxis, yaxis);
        pjs.setValues(minX, maxX, minY, maxY, maxA, minA, nX, nY, miPX, maPX, miPY, maPy, data); 
        bindJavascript();
    }
}

var bound = false;
var pjs

function bindJavascript() {
    if(pjs!=null) {
        pjs.bindJavascript(this);
        bound = true;
    }
    if(!bound) setTimeout(bindJavascript, 250);
}
