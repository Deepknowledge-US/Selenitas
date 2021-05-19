import { jsPanel } from 'jspanel4/es6module/jspanel';
import 'jspanel4/es6module/extensions/modal/jspanel.modal';
import 'jspanel4/dist/jspanel.min.css';
import './createPanel.css'
import {sendUpdate} from './createPanelLogic'

import createSlider from '../InputSlider/InputSlider'
import createBoolean from '../InputBoolean/InputBoolean'


const CreatePanel = (props, pub) => {
	
	const order  = props.order
	const items  = props.ui_settings
	const width  = props.width;
	const height = props.height;
	const title  = props.title;
	const x      = props.x;
	const y      = props.y;

	const panelDiv = document.createElement('div');
	panelDiv.className = 'panel_div';
	panelDiv.id = title;

	// console.log(order)
	// createSlider(panelDiv, title, 'slide1', 0, 1, 0.1, 0.5)

	order.forEach(
		(itemName) => {
			const item = items[itemName];
			const currentValue = props[itemName];

			if (item.type === 'slider') 
			{
				createSlider(panelDiv, title, itemName, item.min, item.max, item.step, currentValue, sendUpdate, pub)
			} 
			else if (item.type === 'boolean') 
			{
				createBoolean(panelDiv, title, itemName, currentValue, sendUpdate, pub)
			};
		}
	);

	const newPanel = () => {
		if (document.getElementById(title)==null) {
			jsPanel.create({
				theme: 'dark',
				headerLogo: '<i class="fad fa-home-heart ml-2"></i>',
				headerTitle: title,
				panelSize: {
					width: () => { return Math.min(width, window.innerWidth*0.9);},
					height: () => { return Math.min(height, window.innerHeight*0.6);}
				},
				position: 'left-top ' + x + ' ' + y,
				animateIn: 'jsPanelFadeIn',
				onwindowresize: true,
				content: panelDiv,
					
				onbeforeclose: function() {
					return window.confirm('Do you really want to close the ' + props.title + ' panel?');
				}
			});            
		}
	}

	return(
		<div>{newPanel()}</div>
	)
}

export default CreatePanel
