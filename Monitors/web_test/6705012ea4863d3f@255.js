// https://observablehq.com/@d3/temporal-force-directed-graph@255
import define1 from "./a33468b95d0b15b0@699.js";
import define2 from "./450051d7f1174df8@252.js";

export default function define(runtime, observer) {
  const main = runtime.module();
  const fileAttachments = new Map([["sfhh@4.json",new URL("./files/5c0e56b44362ec8e2621299d2ddce5ac68e4e1b11e08ac4547075b0e6374d9083a589eec442479ef7876be75215b8499cf9463743191cfe01e4ca3cb826135e5",import.meta.url)]]);
  main.builtin("FileAttachment", runtime.fileAttachments(name => fileAttachments.get(name)));
  main.variable(observer()).define(["md"], function(md){return(
md`# Temporal Force-Directed Graph

This notebook visualizes a temporal network which [changes over time](/@d3/modifying-a-force-directed-graph). Each node and link has a *start* and *end* specifying its existence. The data here represents face-to-face interactions at a two-day conference. Data: [SocioPatterns](/d/89ebc0681ca51806)`
)});
  main.variable(observer("viewof time")).define("viewof time", ["Scrubber","times"], function(Scrubber,times){return(
Scrubber(times, {
  delay: 100, 
  loop: true,
  format: date => date.toLocaleString("en", {
    month: "long", 
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    timeZone: "UTC"
  })
})
)});
  main.variable(observer("time")).define("time", ["Generators", "viewof time"], (G, _) => G.input(_));
  main.variable(observer("chart")).define("chart", ["d3","width","height","invalidation","drag"], function(d3,width,height,invalidation,drag)
{
  const simulation = d3.forceSimulation()
      .force("charge", d3.forceManyBody())
      .force("link", d3.forceLink().id(d => d.id))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .on("tick", ticked);

  const svg = d3.create("svg")
      .attr("viewBox", [-width / 2, -height / 2, width, height]);

  let link = svg.append("g")
      .attr("stroke", "#999")
      .attr("stroke-opacity", 0.6)
    .selectAll("line");

  let node = svg.append("g")
      .attr("stroke", "#fff")
      .attr("stroke-width", 1.5)
    .selectAll("circle");

  function ticked() {
    node.attr("cx", d => d.x)
        .attr("cy", d => d.y);

    link.attr("x1", d => d.source.x)
        .attr("y1", d => d.source.y)
        .attr("x2", d => d.target.x)
        .attr("y2", d => d.target.y);
  }

  invalidation.then(() => simulation.stop());

  return Object.assign(svg.node(), {
    update({nodes, links}) {

      // Make a shallow copy to protect against mutation, while
      // recycling old nodes to preserve position and velocity.
      const old = new Map(node.data().map(d => [d.id, d]));
      nodes = nodes.map(d => Object.assign(old.get(d.id) || {}, d));
      links = links.map(d => Object.assign({}, d));

      node = node
        .data(nodes, d => d.id)
        .join(enter => enter.append("circle")
          .attr("r", 5)
          .call(drag(simulation))
          .call(node => node.append("title").text(d => d.id)));

      link = link
        .data(links, d => [d.source, d.target])
        .join("line");

      simulation.nodes(nodes);
      simulation.force("link").links(links);
      simulation.alpha(1).restart().tick();
      ticked(); // render now!
    }
  });
}
);
  main.variable(observer("update")).define("update", ["data","contains","time","chart"], function(data,contains,time,chart)
{
  const nodes = data.nodes.filter(d => contains(d, time));
  const links = data.links.filter(d => contains(d, time));
  chart.update({nodes, links});
}
);
  main.variable(observer("data")).define("data", ["FileAttachment"], async function(FileAttachment){return(
JSON.parse(await FileAttachment("sfhh@4.json").text(), (key, value) => key === "start" || key === "end" ? new Date(value) : value)
)});
  main.variable(observer("times")).define("times", ["d3","data","contains"], function(d3,data,contains){return(
d3.scaleTime()
  .domain([d3.min(data.nodes, d => d.start), d3.max(data.nodes, d => d.end)])
  .ticks(1000)
  .filter(time => data.nodes.some(d => contains(d, time)))
)});
  main.variable(observer("contains")).define("contains", function(){return(
({start, end}, time) => start <= time && time < end
)});
  main.variable(observer("height")).define("height", function(){return(
680
)});
  main.variable(observer("drag")).define("drag", ["d3"], function(d3){return(
simulation => {
  
  function dragstarted(event, d) {
    if (!event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }
  
  function dragged(event, d) {
    d.fx = event.x;
    d.fy = event.y;
  }
  
  function dragended(event, d) {
    if (!event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }
  
  return d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended);
}
)});
  main.variable(observer("d3")).define("d3", ["require"], function(require){return(
require("d3@6")
)});
  const child1 = runtime.module(define1);
  main.import("swatches", child1);
  const child2 = runtime.module(define2);
  main.import("Scrubber", child2);
  return main;
}
