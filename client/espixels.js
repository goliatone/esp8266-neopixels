/* ==========================================================
*
* huepicker.js
*
* 2012 Franco Trimboli (@sunpazed)
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ========================================================== */

// Terrible global for Hue colour [R,G,B]
var hueColour = [0,0,0];

// EDIT: Host URL endpoint for the REST API
var lighthost = "http://192.168.1.146";
// URL string to control light
var state = false;

function makeHuePicker() {

    // make a canvas
    var canvas = document.getElementById("canvas");
    var ctx = canvas.getContext("2d");

    // set up gradient
    var grad = ctx.createLinearGradient(0, 120,
    canvas.width, canvas.height);
    grad.addColorStop(0, '#fa6c0c');
    grad.addColorStop(0.08, '#f6300a');
    grad.addColorStop(0.21, '#d11b7e');
    grad.addColorStop(0.35, '#7425b1');
    grad.addColorStop(0.52, '#0a62da');
    grad.addColorStop(0.68, '#00c000');
    grad.addColorStop(0.82, '#f6ef2a');
    grad.addColorStop(0.99, '#fa6c0c');

    // fill rect
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // mind mouse to canvas to retrieve RGB
      $('canvas').bind('mousemove', function(event){
        var x = event.pageX - event.currentTarget.offsetLeft
        var y = event.pageY - event.currentTarget.offsetTop;
        var ctx = document.getElementById('canvas').getContext('2d');
        var imgd = ctx.getImageData(x, y, 1, 1);
        var data = imgd.data;
        // retrieve RGB pixel under mouse
        var out = $('#result');
        hueColour = [data[0],data[1],data[2]];
        //update that global!
        var hexString = RGBtoHex(data[0],data[1],data[2]);
        // convert to hex to update our button
        out.attr("style","background-color: #" + hexString + ";");
        // button changes to colour
      });
}

function updateHue() {

    // Log RGB
    console.log(hueColour);

    // Create request (only XY set, what about brightness?)
    var request = {
        "brightness": (window.bri || 0.5) * 10,
        "red": hueColour[0],
        "green": hueColour[1],
        "blue": hueColour[2],
        "on": true
    };


    // var jbulbs = JSON.stringify(request);
    var jbulbs = request;
    console.log(jbulbs);

    console.info("curl '%s' --data 'red=%s&green=%s&blue=%s' --compressed", lighthost, request.red, request.green, request.blue, request.brightness)

    // Hey Hue there, change for me please!
    $.ajax({
        data : jbulbs,
        // contentType : 'application/json',
        type : 'POST',
        // type : 'GET',
        url: lighthost,
    });
    state = true;

}

// Helper functions
function RGBtoHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B);}
function toHex(N) {
      if (N==null) return "00";
      N=parseInt(N); if (N==0 || isNaN(N)) return "00";
      N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
      return "0123456789ABCDEF".charAt((N-N%16)/16) + "0123456789ABCDEF".charAt(N%16);
}
