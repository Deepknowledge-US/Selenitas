import React, { useContext } from 'react';
import { Card, Form, Input, Row, Col, Button, Slider } from 'antd';
import { NewContext} from '../index'

import {
	modelLoad, 
	modelSetup,
	modelStep,
	modelRun,
	modelSpeed,
	modelViewStats,
	modelViewWindows,
	modelViewFamilies,
	modelViewGrid,
} from './publisherLogic' 

const Publisher = ({ publish }) => {
	const [form] = Form.useForm();
	const {state, dispatch} = useContext(NewContext);
	
	const PublishForm = (
		<Form layout="vertical"	name="basic" form={form} >
			<Row gutter={20}>
				<Col span={8} >
					<Input type='file' onChange={(value) => modelLoad(value,publish)}/>
				</Col>
				<Col span={8} >
					{/* <Button onClick={modelLoad}>	Load	</Button> */}
					<Button onClick={()=>modelSetup(publish,dispatch)}>	Setup	</Button>
					<Button onClick={()=>modelStep(publish)}> 			Step	</Button>
					<Button onClick={()=>modelRun(publish)}> 			Run 	</Button>
					<br/>
					<br/>
					<label>Speed:</label>
					<Slider min={1} max={10} defaultValue={10} onChange={(val)=>modelSpeed(val,publish)} />
				</Col>
				<Col span={8} >
					<Button onClick={()=>modelViewStats(publish)}> 	  view Stats	</Button>
					<Button onClick={()=>modelViewWindows(publish)}>  view Windows 	</Button>
					<Button onClick={()=>modelViewFamilies(publish)}> view Families	</Button>
					<Button onClick={()=>modelViewGrid(publish)}> 	  view Grid 	</Button>
				</Col>
			</Row>
		</Form>
	)

	return (
		<Card title="Control Panel" >
			{PublishForm}
		</Card>
	);
}

export default Publisher;
