import React from 'react';
import { Card, Button, Form, Input, Row, Col } from 'antd';

const Connection = ({ connect, disconnect, connectBtn }) => {
	const [form] = Form.useForm();
	const record = {
		host: '127.0.0.1',
		clientId: `mqttjs_ + ${Math.random().toString(16).substr(2, 8)}`,
		port: 8083,
		topic: 'from_client/#'
	};
	const onFinish = (values) => {
		const { host, port } = values;
		// const qos = 0;
		const url = `ws://${host}:${port}/mqtt`;
		const options = {
			keepalive: 30,
			protocolId: 'MQTT',
			protocolVersion: 4,
			clean: true,
			reconnectPeriod: 1000,
			connectTimeout: 30 * 1000,
			will: {
				topic: 'WillMsg',
				payload: 'Connection Closed abnormally..!',
				qos: 0,
				retain: false
			},
			rejectUnauthorized: false
		};
		options.clientId = record.clientId;
		
		connect(url, options);
	};

	const handleConnect = () => {
		form.submit();
	};

	const handleDisconnect = () => {
		disconnect();
	};

	const ConnectionForm = (
		<Form
			layout="vertical"
			name="basic"
			form={form}
			initialValues={record}
			onFinish={onFinish}
		>
			<Row gutter={20}>
				<Col span={8}>
					<Form.Item
						label="Host"
						name="host"
					>
						<Input />
					</Form.Item>
				</Col>
				<Col span={8}>
					<Form.Item
						label="Port"
						name="port"
					>
						<Input />
					</Form.Item>
				</Col>
			</Row>
			<Row gutter={20}>
				<Col span={8}>				
					<Button type="primary" onClick={handleConnect}>{connectBtn}</Button>
					<Button danger onClick={handleDisconnect}>Disconnect</Button>
				</Col>
			</Row>
		</Form>
	)

	return (
		<Card title="Connection" >
			{ConnectionForm}
		</Card>
	);
}

export default Connection;
