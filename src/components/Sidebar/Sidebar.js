import React, { useState } from 'react';

import HookMqtt from '../Mqtt/index'

import { Layout, Menu }                     from 'antd';
import { ApartmentOutlined,	TeamOutlined }  from '@ant-design/icons';

import './sidebar.css'

const { Sider }     = Layout;
const { SubMenu }   = Menu;


function SidebarContent(props) {

    const [collapsed, collapseFunction] = useState(true);

    const onCollapse = (e) => {
		console.log(collapsed);
        collapseFunction(e);
	};

    return(
        <Sider id='sideBar' collapsible collapsed={collapsed} onCollapse={onCollapse}>
            <Menu theme='dark' id="sidebar-menu" defaultSelectedKeys = {['1']} mode = "inline">
                <SubMenu   key = "sub1" icon = {<ApartmentOutlined />} title = "Connection">
                    <HookMqtt id='mqtt' />
                </SubMenu>
                <SubMenu   key = "sub2" icon = {<TeamOutlined />} title = "A thing">
                    <Menu.Item key = "6">Team 10</Menu.Item>
                    <Menu.Item key = "8">Team 20</Menu.Item>
                </SubMenu>
            </Menu>
        </Sider>
    );
}

export default SidebarContent;

