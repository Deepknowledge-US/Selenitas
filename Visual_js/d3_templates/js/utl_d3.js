// /*
// ####################################
// ########## CREATE DATASET ##########
// ####################################

// define a javascript object to hold our dataset
var dataset = {
	// points will be x,y coordinates
	points: [],
	numPoints: 0,
	color: "#913f92",
	radius: 2,
	minX: 0,
	maxX: 500,
	minY: 0,
	maxY: 1000,
};

// /*
// ########################################################################
// ##### This is where D3 gets extremely dense with function chaining #####
// ########################################################################

// ####################################
// ######### DEFINE D3 SCALES #########
// ####################################

// Define SVG size and padding (extra white space to prevent overlap).
var width = 600;
var height = 250;
var padding = {
	// buffer used to prevent chart element overlap
	top: 20,
	right: 25,
	bottom: 30,
	left: 60,
};

// D3 scales are used to translate your numerical data into svg space

// define scales
var xScale = d3.scale
	.linear() // predefined d3 function to create scale
	.domain([dataset.minX, dataset.maxX]) // domain defines the coordinate system of your data
	.range([padding.left, width - padding.right]); // range defines the coordinate system of your svg

var yScale = d3.scale
	.linear()
	.domain([dataset.minY, dataset.maxY])
	.range([height - padding.bottom, padding.top]); // notice that the larger value is the first listed
// in the yScale range.

// define axis behavior in D3
var xAxis = d3.svg
	.axis() // the d3 axis object
	.scale(xScale) // set the scale to what we just defined
	.orient("bottom") // orient tick direction
	.ticks(5); // try to do 5 ticks. Won't always be this many

var yAxis = d3.svg.axis().scale(yScale).orient("left").ticks(5);
// /*

// ####################################
// ######## BUILD SVG USING D3 ########
// ####################################

// Use D3 to insert an SVG element into our HTML document
var svg = d3
	.select("#container") // grab the <div> tag which has the id #svgcontainer
	.append("svg") // append an <svg> tag into this container
	.attr("width", width) // set the svg's width attribute
	.attr("height", height); // set the svg's height attribute

// /*
// actually insert x axis into html
svg
	.append("g") // new group element
	.attr("class", "xAxis") // give it the css class 'xAxis'
	.attr("transform", "translate" + "(0," + (height - padding.bottom) + ")") // translate the axis to the bottom of the svg
	.call(xAxis); // refer to axis variables to define scale behavior

svg
	.append("g")
	.attr("class", "yAxis")
	.attr("transform", "translate(" + padding.left + "," + 0 + ")")
	.call(yAxis);

// /*
// ####################################
// ######### Helper Functions #########
// ####################################

// event handlers for interactivity
var handleMouseOver = function (d, i) {
	// Use D3 to select element, change color and size
	d3.select(this)
		.attr({
			fill: "orange",
			r: dataset.radius ,
		})
		.attr("stroke", "black")
		.attr("stroke-width", "1px");

	// Specify where to put label of text
	svg
		.append("text")
		.attr({
			id: "t" + Math.round(d.x) + "-" + Math.round(d.y) + "-" + i, // Create an id for text so we can select it later for removing on mouseout
			x: function () {
				return xScale(d.x) - 30;
			},
			y: function () {
				return yScale(d.y) - 15;
			},
			})
		.text(function () {
			return [Math.round(d.x), Math.round(d.y)]; // Value of the text
		});
};

var handleMouseOut = function (d, i) {
  // Use D3 to select element, change color back to normal
	d3.select(this)
		.attr({
			fill: dataset.color,
			r: dataset.radius,
		})
		.attr("stroke", "none");

	// Select text by id and then remove
	d3.select("#t" + Math.round(d.x) + "-" + Math.round(d.y) + "-" + i).remove(); // Remove text location
};

// define a function to do the plotting to avoid code redundancy
var updateChart = function () {
	// Update scale domains.
	// redefining the x and y minimums and maximums
	xScale.domain([
		d3.min(dataset.points, function (d) {
			// return minimum x value
			return d.x;
		}),
		d3.max(dataset.points, function (d) {
			// return maximum x value
			return d.x;
		}),
	]);
	yScale.domain([
		d3.min(dataset.points, function (d) {
			// return minimum y value
			return d.y;
		}),
		d3.max(dataset.points, function (d) {
			// return maximum y value
			return d.y;
		}),
	]);

	// here's the d3 magic
	// this basically primes the svg to do stuff with <circle> tags

	// d3 does inventory and figures out how many <circle> tags currently exist in svg.
	var d3Circles = svg.selectAll("circle").data(dataset.points); // rebind dataset.points just in case it's been updated

	// if there aren't enough circle tags, .enter().append() creates new ones for the data points
	d3Circles
		.enter()
		.append("circle")
		.attr("cx", function (d) {
			return xScale(0); // initialize circle at origin
		})
		.attr("cy", function (d) {
			return yScale(0); // initialize circle at origin
		})
		.on("mouseover", handleMouseOver) // bind mouse-over event to each circle
		.on("mouseout", handleMouseOut); // bind mouse-off event to each circle

	// exit().remove() will trash extra circles for us if we have too many
	d3Circles
		.exit() // get svg elements we need to remove
		.transition() // default transition
		.attr("cx", function (d) {
			return xScale(0); // initialize circle at origin
		})
		.attr("cy", function (d) {
			return yScale(0); // initialize circle at origin
		})
		.remove(); // get rid of em

	// update circle locations, both new and old with fancy transitions
	d3Circles
		.attr("fill", dataset.color) // make dots purple by default
		.attr("r", dataset.radius ) // make radius smaller
		.attr("fill", "gray") // make dots gray by default
		.attr("cx", function (d) {
		return xScale(d.x); // move circle to new x coordinates
		})
		.attr("cy", function (d) {
		return yScale(d.y); // move circle to new y coordinates
		});

	// update axes to represent new values
	svg.select(".xAxis").call(xAxis);

	svg.select(".yAxis").call(yAxis);
};

// run updateChart to plot initial set of points
updateChart();

// function for adding an additional point to our dataset
var addPoint = function (param) {
  dataset.numPoints++;
  var yCor = GB[param][GB[param].length - 1]
  console.log(yCor)
  var point = {
    x: dataset.numPoints,
    y: yCor
  };

  dataset.points.push(point);
  updateChart();
};


// function for regenerating random data for our dataset
var regenerateData = function (param) {
  // updateDataset(param);
  addPoint(param)
  updateChart();
};

