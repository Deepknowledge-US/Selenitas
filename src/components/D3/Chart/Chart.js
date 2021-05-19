import React, { useState } from 'react';
import { scaleOrdinal, scaleLinear } from 'd3-scale';
import { schemeCategory10 } from 'd3-scale-chromatic';
import { line as d3Line, curveBasis } from 'd3-shape';
import { min, max } from 'd3-array';
import { axisBottom, axisLeft } from 'd3-axis';
import { select } from 'd3-selection';

import './chart.css';


const Chart = (props) => {

	const svgWidth 	= 500;
	const svgHeight = 300;

	const margin 	= { top: 20, right: 80, bottom: 30, left: 50 };
	const width 	= svgWidth - margin.left - margin.right;
	const height 	= svgHeight - margin.top - margin.bottom;

	const x 		= scaleLinear().range([0, width]);
	const y 		= scaleLinear().range([height, 0]);
	const z 		= scaleOrdinal(schemeCategory10);

	const line = d3Line()
		.curve(curveBasis)
		.x(d => x(d.time))
		.y(d => y(d.value));

	const [data, updateData] = useState(props.data);
	

	x.domain([
		min(data, c => min(c.values, d => d.time)),
		max(data, c => max(c.values, d => d.time)),
	]);
	y.domain([
		min(data, c => min(c.values, d => d.value)),
		max(data, c => max(c.values, d => d.value)),
	]);
	z.domain(data.map(c => c.id));

	if ( y.domain()[0] - y.domain()[1] == 0 ) {y.domain([0,1])}

	return(
		<>
			<svg width={svgWidth} height={svgHeight}>
				<g transform={`translate(${margin.left}, ${margin.top})`}>
					<g
						className="axis axis--x"
						transform={`translate(0, ${height})`}
						ref={node => select(node).call(axisBottom(x))}
					/>
					<g className="axis axis--y" ref={node => select(node).call(axisLeft(y))}>
						<text transform="rotate(-90)" y="6" dy="0.71em" fill="#000">
							value
						</text>
					</g>
					{data.map(trackedVar => {
						const [lastD] = trackedVar.values.slice(-1);
						return (
							<g className="trackedVar" key={trackedVar.id}>
								<path
									className="line"
									d={line(trackedVar.values)}
									style={{ stroke: z(trackedVar.id) }}
								/>
								<text
									transform={`translate(${x(lastD.time)}, ${y(lastD.value)})`}
									x={3}
									dy="0.35em"
									style={{ font: '10px sans-serif' }}
								>
									{trackedVar.id}
								</text>
							</g>
						);
					})}
				</g>
			</svg>
		</>
	);
};

export default Chart

