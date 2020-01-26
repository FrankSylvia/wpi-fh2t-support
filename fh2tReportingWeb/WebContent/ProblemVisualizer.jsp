<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Problem Visualizer</title>
<style type="text/css">
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0;
	margin-bottom: 0;
}
</style>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <script src="scripts/js/jquery.js" type="text/javascript"></script>
        <link rel="stylesheet" href="scripts/shared/fonts/fonts.css" />
        <script src="scripts/shared/libs/d3/d3.min.js"></script>
        <script src="scripts/shared/libs/geom.js/geom.min.js"></script>
        <script src="scripts/shared/libs/jquery/jquery-2.1.0.min.js"></script>
        <script src="scripts/shared/libs/bootstrap-3.3.4-dist/js/bootstrap.min.js"></script>
        <link rel="stylesheet" href="scripts/shared/css/navbar.css" />
        <link rel="stylesheet" href="scripts/shared/libs/bootstrap-3.3.4-dist/css/bootstrap.min.css" />
        <link rel="stylesheet" href="scripts/shared/libs/bootstrap-3.3.4-dist/css/no-btn-focus.css" />
        <script src="scripts/js/jquery-ui.min.js" type="text/javascript"></script>
	<script src="scripts/shared/libs/gmath/gmath-stable.min.js"></script>
</head>
<body style=background-color:blue>

<div id="mainCanvas" style="position:relative; margin:auto; left:0; right:0; width:400px; background-color:blue"></div>

<script>

var X_COORD = 0;
var Y_COORD = 1;
var STATE = 2;
var ETIME = 3;
var HEIGHT = 4;
var BCOLOR = 5;
var FCOLOR = 6;
var ACTION = 7;
var METHOD = 8;

var eventH = 60;
var eventW = 300;
var eventL = 50;
var strEventH = eventH + "px";
var strEventW = eventW + "px";
var strEventL = eventL + "px";

var errorH = 25;
var errorW = 200;
var errorL = 100;
var strErrorH = errorH + "px";
var strErrorW = errorW + "px";
var strErrorL = errorL + "px";

var actionH = 25;
var actionW = 250;
var actionL = 75;
var strActionH = actionH + "px";
var strActionW = actionW + "px";
var strActionL = actionL + "px";

var rawData="";
var gmAPIData="";
var attemptstats;
var data = [];
var start_state = "";
var goal_state = "";

function loadData(attemptID)
{

	alert("Hello world");
	data = [];
	document.getElementById("mainCanvas").innerHTML="";
	var dCounter=1;
	var ycoord = 10;
	var elapsedTime = 0.0;

	var txt = '{"expr_ascii":"a+b+c", "action":"Commute", "method":"noop" }';
	//var obj = JSON.parse(txt);

	alert("after");

	
	var loadedCSV = "events.csv";
	d3.csv(loadedCSV, function(allData) {


	    allData.forEach(function(d, i) {
			var actionText = ("" + d["action"]).trim();
			alert(d["expr_ascii"] + " " + actionText);
				if (actionText == "start") {
					data.push([eventL, ycoord, d["expr_ascii"], elapsedTime, eventH,  "white", 0, d["action"],d["method"]]);
					ycoord = ycoord + 25 + eventH;
					start_state = ("" + d["expr_ascii"]).trim();
					goal_state  = ("" + d["method"]).trim();
				}
				else if (actionText == "error") {
					data.push([eventL, ycoord, d["expr_ascii"], elapsedTime, errorH,  "yellow", 0,  d["action"],d["method"]]);
					ycoord = ycoord + 25 + errorH;
				}
				else if (actionText == "reset") {
					data.push([eventL, ycoord, d["expr_ascii"], elapsedTime, errorH,  "red", 0, d["action"],d["method"]]);
					ycoord = ycoord + 25 + errorH;

					data.push([eventL, ycoord, start_state, elapsedTime, eventH,  "white", 0, "start",d["method"]]);
					ycoord = ycoord + 25 + eventH;
				}
				else {
					data.push([eventL, ycoord, "action", elapsedTime, errorH,  "lightblue", 0, d["action"],d["method"]]);
					ycoord = ycoord + 25 + errorH;

					data.push([eventL, ycoord, d["expr_ascii"], elapsedTime, eventH, "white", 0, "state",d["method"]]);
					ycoord = ycoord + 25 + eventH;
					dCounter++;	
				}		
	});
	init();	
	});
}

function init()
{
document.getElementById("mainCanvas").innerHTML="";
var previousState="";
var currentTime=0;
var timeInterval=20;


alert("init()1");
 var c10 = d3.scale.category10();
 var svg = d3.select("#mainCanvas")
   .append("svg")
   .attr("width", "950px")
   .attr("height", (data.length-1)*75+"px");

 var drag = d3.behavior.drag()
   .on("drag", function(d, i) {
     d[0] += d3.event.dx
     d[1] += d3.event.dy
     d3.select(this).attr("x", d[0]).attr("y", d[1]);
     d3.select(this).select("rect").attr("x", d[0]).attr("y", d[1]);
     d3.select("#dl_"+i).style("left", d[0]+"px").style("top", d[1]+"px");	 
	 
	 d3.selectAll(".link").each(function(l, li) {
       if (li == i) {
         d3.select(this).attr("x1", d[0]+eventH).attr("y1", d[1]);
       } else if (li+1 == i) {
         d3.select(this).attr("x2", d[0]+eventH).attr("y2", d[1]);
       }
     });
   });


data.forEach(function(d, i){
	
	if (i > 0) {
		if(i > data.length-2)
		return;

		var links = svg
		.append("line")
		.attr("class", "link")
		.attr("x1", d[X_COORD]+150)
		.attr("x2", data[i+1][0]+150)
		.attr("y1", d[HEIGHT]) 
		.attr("y2", data[i+1][1])
		.attr("stroke", "black")
	}
});

alert("init()2");
   	var elapsedTime=0;
	gmath.ui = gmath.ui || {};
   	data.forEach(function(d,i){

	alert("init()" + d[ACTION]);
 
	if (d[ACTION] == "error") {
		var div = document.createElement("div");
		div.id="dl_"+i;
		div.style.width = strErrorW;
		div.style.height = strErrorH;
		div.style.position="absolute";
		div.style.left= strErrorL;
		div.style.borderRadius="5px";
		div.style.top=d[Y_COORD]+"px";
		div.style.backgroundColor = d[BCOLOR];
		div.style.color = "black";
	//	div.innerHTML = "<span id='dlDisplay_"+i+"' style='width:" + strEventW + "'></span><span style='position: absolute; width:275px; left:0; top:0; margin-left: -290px; text-align: right'></span>";
		div.innerHTML += "<p style=text-align:center;font-size:18px;>" + d[METHOD] + "</p>";
	}
	else if (d[ACTION] == "reset") {
		var div = document.createElement("div");
		div.id="dl_"+i;
		div.style.width = strEventW;
		div.style.height = strErrorH;
		div.style.position="absolute";
		div.style.left= strEventH;
		div.style.borderRadius="5px";
		div.style.top=d[Y_COORD]+"px";
		div.style.backgroundColor = d[BCOLOR];
		div.style.color = "black";
		div.innerHTML = "<p style=text-align:center;font-size:18px;>reset</p>";
	}
	else { 

		if (d[STATE] == "action") {
			var div = document.createElement("div");
			div.id="dl_"+i;
			div.style.width = strActionW;
			div.style.height = strActionH;
			div.style.position="absolute";
			div.style.left= strActionL;
			div.style.borderRadius="5px";
			div.style.top=d[Y_COORD]+"px";
			div.style.backgroundColor = d[BCOLOR];
			div.style.color = "black";
			div.innerHTML = "<p style=text-align:center;font-size:18px;>" + d[ACTION] + "</p>";
		}                   
		else {
	   		alert("d[STATE]=" + d[STATE]);
			var div = document.createElement("div");
			div.id="dl_"+i;
			div.style.width = strEventW;
			div.style.height = strEventH;
			div.style.position="absolute";
			div.style.left= strEventH;
			div.style.borderRadius="5px";
			div.style.top=d[Y_COORD]+"px";
			if (d[STATE] == goal_state) {
				div.style.backgroundColor = "green";
			}
			else {
				div.style.backgroundColor = d[BCOLOR];
			}
			div.style.color = "black";
			div.innerHTML = "<span id='dlDisplay_"+i+"' style='width:" + strEventW + "'></span><span style='position: absolute; width:275px; left:0; top:0; margin-left: -290px; text-align: right'></span>";
	   		alert("END: " + d[STATE]);
		}
	}
	elapsedTime=parseInt(d[ETIME]);

	document.getElementById("mainCanvas").appendChild(div);
	
	gmath.ui.Pill = (function() {
		var GMPill = function() {
		this.loadSettings();
	}	
	
	GMPill.prototype.loadSettings = function() 
	{
   		alert("loadsettings1");
		var svgm = d3.select('#dlDisplay_'+i).append('svg').style('margin-top', '5px').style('margin-left', '0px').style('width', eventW);
   		alert("loadsettings2");
		//var model = new gmath.AlgebraModel(((d[STATE].indexOf("ANSWERED ")!==-1)?d[STATE].replace("ANSWERED ",""):d[STATE]));
   		alert("loadsettings3");
		//var view = new gmath.AlgebraView(model, svgm, {interactive: false, "inactive_color": "black", "auto_resize_container":true, "font_size": 20, "normal_font":{"family":"Kalam","id":"_8a041c46eb608104"},"italic_font":{"family":"Kalam","id":"_8a041c46eb608104"}, pos: [150, 30]})
   		alert("loadsettings4");
		view.init();
   		alert("loadsettings5");
	}
	return GMPill;
})();
	var tempPill = new gmath.ui.Pill();
	});	
	setTimeout(function(){
		data.forEach(function(d,i)
		{
			if(i<data.length-1)
			{
				var translate=document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].childNodes[3].getAttribute("transform");
				//document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].innerHTML='<circle cx="'+(20+parseFloat(document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].getBoundingClientRect().width)*parseFloat(0))+'" cy="'+(parseFloat(document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].getBoundingClientRect().height)*parseFloat(d[6])-20)+'" r="15" fill="rgba(255,0,0,0.5)" transform=" '+translate+'"/>'+document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].innerHTML;
			}
		});
	}, 1000);
	
}
var tester = "3137";
loadData(tester);
</script>
</body>
</html>
