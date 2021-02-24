if (!jsPanel.dock) {

    jsPanel.dock = {
        version: '1.1.3',
        date: '2020-06-04 08:38',
        defaults: {
            position: { my: 'left-top', at: 'right-top' },
            linkSlaveHeight: false,
            linkSlaveWidth: false,
            callback: false
        }
    };

    const dockPanel = function(config) {
        let master,
            slave = this; // this refers to slave panel
        this.slaveconfig = Object.assign({}, jsPanel.dock.defaults, config);
        if (this.slaveconfig.master && this.slaveconfig.master.nodeType === 1) {
            master = this.slaveconfig.master;
        } else {
            master = document.querySelector(this.slaveconfig.master);
        }
        if (!master) {
            // if master does not exist show error panel return false
            if (this.errorReporting) {
                let err = '&#9664; COULD NOT DOCK PANEL &#9658;<br>The configured master panel to does not exist';
                jsPanel.errorpanel(err);
            }
            return false;
        } else {
            if (!master.slaves) {
                master.slaves = new Set();
            }
            if (!master.handlers) {
                master.handlers = {};
            }
            // set interactions between master and slaves
            if (!master.handlers.fronted) {
                master.options.onfronted.push(() => {
                    let zI = master.style.zIndex;
                    master.slaves.forEach(sl => {
                        sl.style.zIndex = zI;
                    });
                    return true;
                });
                master.handlers.fronted = true;
            }
            if (!master.handlers.smallified) {
                master.options.onsmallified.push(() => {
                    master.slaves.forEach(sl => {
                        sl.smallify().reposition();
                    });
                    return true;
                });
                master.handlers.smallified = true;
            }
            if (!master.handlers.unsmallified) {
                master.options.onunsmallified.push(() => {
                    master.slaves.forEach(sl => {
                        sl.unsmallify().reposition();
                    });
                    return true;
                });
                master.handlers.unsmallified = true;
            }
            if (!master.handlers.closed) {
                master.options.onclosed.push(() => {
                    master.slaves.forEach(sl => {
                        sl.close();
                    });
                    return true;
                });
                master.handlers.closed = true;
            }
            if (!master.handlers.minimized) {
                master.options.onminimized.push(() => {
                    master.slaves.forEach(sl => {
                        sl.minimize();
                    });
                    return true;
                });
                master.handlers.minimized = true;
            }
            if (!master.handlers.maximized) {
                master.options.onmaximized.push(() => {
                    master.slaves.forEach(sl => {
                        sl.normalize();
                        if (sl.slaveconfig.linkSlaveHeight) {
                            let height = window.getComputedStyle(master).height;
                            sl.resize({ height: height });
                        }
                        if (sl.slaveconfig.linkSlaveWidth) {
                            let width = window.getComputedStyle(master).width;
                            sl.resize({ width: width });
                        }
                        sl.reposition();
                    });
                    return true;
                });
                master.handlers.maximized = true;
            }
            if (!master.handlers.normalized) {
                master.options.onnormalized.push(() => {
                    master.slaves.forEach(sl => {
                        sl.normalize();
                        if (sl.slaveconfig.linkSlaveHeight) {
                            let height = window.getComputedStyle(master).height;
                            sl.resize({ height: height });
                        }
                        if (sl.slaveconfig.linkSlaveWidth) {
                            let width = window.getComputedStyle(master).width;
                            sl.resize({ width: width });
                        }
                        sl.reposition();
                    });
                    return true;
                });
                master.handlers.normalized = true;
            }
        }

        let position = Object.assign({}, this.slaveconfig.position, {
            of: master,
            minLeft: false,
            minTop: false,
            maxLeft: false,
            maxTop: false,
            autoposition: false,
            modify: false
        });
        if (!position.my) {
            position.my = jsPanel.dock.defaults.position.my;
        }
        if (!position.at) {
            position.at = jsPanel.dock.defaults.position.at;
        }
        slave.options.position = position;
        ['smallify', 'minimize', 'normalize', 'maximize'].forEach(function(ctrl) {
            slave.setControlStatus(ctrl, 'remove');
        });
        if (this.slaveconfig.linkSlaveHeight) {
            let height = window.getComputedStyle(master).height;
            slave.resize({ height: height });
        }
        if (this.slaveconfig.linkSlaveWidth) {
            let width = window.getComputedStyle(master).width;
            slave.resize({ width: width });
        }
        // position slave
        slave.reposition(position);
        // set necessary slave panel options
        slave.dragit('disable');
        slave.resizeit('disable');
        slave.options.minimizeTo = false;
        // remove slave from master.slaves Set when slave is closed
        slave.options.onclosed.push(() => {
            master.slaves.delete(slave);
        });

        slave.options.onfronted.push(panel => {
            let zI = panel.style.zIndex;
            master.style.zIndex = zI;
            master.slaves.forEach(sl => {
                sl.style.zIndex = zI;
            });
        });

        // set necessary master options
        master.reposSlave = function() {
            if (document.querySelector('#' + slave.id)) {
                slave.reposition();
            }
        };
        if (master.options.dragit) {
            master.options.dragit.drag.push(master.reposSlave);
        }

        master.resizeSlave = function() {
            if (document.querySelector('#' + slave.id)) {
                slave.reposition();
                if (slave.slaveconfig.linkSlaveHeight) {
                    let h = window.getComputedStyle(master).height;
                    slave.resize({
                        height: h
                    });
                }
                if (slave.slaveconfig.linkSlaveWidth) {
                    let w = window.getComputedStyle(master).width;
                    slave.resize({
                        width: w
                    });
                }
            }
        };
        if (master.options.resizeit) {
            master.options.resizeit.resize.push(master.resizeSlave);
        }

        master.slaves.add(slave);

        slave.dockedTo = master.id;

        if (this.slaveconfig.callback) {
            this.slaveconfig.callback.call(slave, master, slave);
        }

        return slave;
    };

    jsPanel.extend({ dock: dockPanel });

}
