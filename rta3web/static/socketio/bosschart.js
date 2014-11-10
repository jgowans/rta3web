$(document).ready(function() {
    WEB_SOCKET_SWF_LOCATION = "/static/WebSocketMain.swf";
    WEB_SOCKET_DEBUG = true;

    // connect to the websocket
    var socket = io.connect('/boss');
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

var message = {};
var pjs;
var data = new Array();
var freqs = new Array();
var headings = new Array();
var dataPos = -1;
var maxLength = 100;
var pause = false;
var newMessage = false;
var mX;
function loadData(id, freq, spectrum, maxx, minx, maxy, miny, heading, xaxis, yaxis) {
        pjs = Processing.getInstanceById('boss');
    if (pjs) {
        // alert("LOAD DATA");
        
        div = document.getElementById("graphdiv");
        data.push(eval( spectrum ));
        freqs = (eval( freq ));
        headings.push(heading);
        // console.log(miny);
        pjs.setVals(data[0], freqs, maxx, minx, maxy, miny);
        pjs.setLabels(heading, xaxis, yaxis);

        mX = minx;
    }
}
function reloadData(id) {
    if (pjs) {
        if(newMessage){
            data.push(eval(message['spectrum']));
            headings.push(message['heading']);
            newMessage = false;
        }
        if (!pause)
        {
            console.log("adding data");
            if (data.length == maxLength){data.shift();headings.shift();}
            else if (data.length > maxLength){
            data = data.slice(data.length - maxLength,data.length);
            headings = headings.slice(headings.length - maxLength,headings.length);
            }
            // $( "#slide" ).slider( "option", "max", data.length -1 );
            // $( "#slide" ).slider( "option", "value", data.length -1 );
            dataPos = data.length - 1;
            // <!-- $( "#timestampT" ).text(headings[dataPos]); -->
        }
        
        var freqs = eval(message['freqs']);

        pjs.setLabels(headings[dataPos], message['xaxis'], message['yaxis']);
        if (freqs.length == 0){
            console.log("freqs len = 0")
            pjs.resetVals(data[dataPos], message['miny'], message['maxy']);
        }
        else{
            console.log("freqs len = " + freqs.length + " resetting freqs");
            pjs.setVals(freqs, data[dataPos], message['maxx'], message['minx'], message['maxy'], message['miny']);
        }
    } 
}
function togglePause(){
    if (pause){
        pause = false;
        // $( "#slide ").slider( "option", "disabled", true);
        $( "#pauseB" ).button( "option", "label", "Pause");}
    else{
        pause = true;
        // $( "#slide ").slider( "option", "disabled", false);
        $( "#pauseB" ).button( "option", "label", "Resume");}
}
$(function() {
    // $( "#slide" ).slider({max: 1,
    //                          min: 0,
    //                          disabled: true,
    //                          change: function(event, ui){
    //                             dataPos = $( "#slide" ).slider( "value" );},
    //                          slide: function(event, ui){
    //                             $( "#timestampT" ).text(headings[$( "#slide" ).slider( "value" )]);}
    //                          });
    $("#pauseB").button()
            .click(function( event ) {
                togglePause();
            });
    $("#loadB").button();
    $("#backB").button()
    .click(function( event ) {
        if (dataPos > 0 ) {
        dataPos = dataPos - 1;
        reloadData();}
    });
    $("#forwardB").button()
    .click(function( event ) {
        if (dataPos < data.length ) {
        dataPos = dataPos + 1;
        reloadData();}
    });
});