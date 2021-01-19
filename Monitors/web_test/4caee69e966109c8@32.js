// https://observablehq.com/@mbostock/disposal@32
export default function define(runtime, observer) {
  const main = runtime.module();
  main.variable(observer()).define(["md"], function(md){return(
md`# Disposal

This is a little helper to detect when an element is removed from the DOM. It functions similarly to [invalidation](https://github.com/observablehq/notebook-stdlib/blob/master/README.md#invalidation), except that you don’t need to pass the invalidation promise around. The downside is that it only works if the resource you want to dispose is attached to a DOM element.`
)});
  main.variable(observer("disposal")).define("disposal", ["MutationObserver"], function(MutationObserver){return(
function disposal(element) {
  return new Promise(resolve => {
    requestAnimationFrame(() => {
      const target = element.closest(".observablehq");
      if (!target) return resolve();
      const observer = new MutationObserver(mutations => {
        if (target.contains(element)) return;
        observer.disconnect(), resolve();
      });
      observer.observe(target, {childList: true});
    });
  });
}
)});
  main.variable(observer()).define(["md","test"], function(md,test){return(
md`This is a test; the count should be three.

${Array.from({length: 3}, test)}`
)});
  main.define("initial count", function(){return(
0
)});
  main.variable(observer("mutable count")).define("mutable count", ["Mutable", "initial count"], (M, _) => new M(_));
  main.variable(observer("count")).define("count", ["mutable count"], _ => _.generator);
  main.variable(observer("test")).define("test", ["html","mutable count","disposal"], function(html,$0,disposal){return(
function test() {
  const span = html`<span>`;
  ++$0.value;
  disposal(span).then(() => --$0.value);
  return span;
}
)});
  return main;
}
