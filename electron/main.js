var app = require('app'); // Module to control application life.
var BrowserWindow = require('browser-window'); // Module to create native browser window.
var Menu = require('menu');

// Report crashes to our server.
require('crash-reporter').start();

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
    if (process.platform != 'darwin')
        app.quit();
});

// This method will be called when Electron has done everything
// initialization and ready for creating browser windows.
app.on('ready', function() {
    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600
    });

    // and load the index.html of the app.
    mainWindow.loadUrl('file://' + __dirname + '/index.html');

    var application_menu = [{
        label: 'menu1',
        submenu: [{
            label: 'Undo',
            accelerator: 'CmdOrCtrl+Z',
            role: 'undo'
        }, {
            label: 'Open',
            accelerator: 'CmdOrCtrl+O',
            click: function() {
                require('electron').dialog.showOpenDialog({
                    properties: ['openFile', 'openDirectory', 'multiSelections']
                });
            }
        }, {
            label: 'submenu1',
            submenu: [{
                label: 'item1',
                accelerator: 'CmdOrCtrl+A',
                click: function() {
                    mainWindow.openDevTools();
                }
            }, {
                label: 'item2',
                accelerator: 'CmdOrCtrl+B',
                click: function() {
                    var wd = require('wd');
                    var browser = wd.remote();
                    // https://github.com/admc/wd/blob/master/examples/deprecated/wait-for-simple.js
                    // https://github.com/vvo/selenium-standalone
                    browser
                        .chain()
                        .init({
                            browserName: 'chrome'
                        })
                        // .init({browserName:'firefox' }  ) //'internet explorer'})
                        // .init({browserName:'internet explorer'})
                        .get("http://admc.io/wd/test-pages/guinea-pig.html");

                    /*
                    WARN - Exception: Unexpected error launching Internet Explorer. Browser zoom level was set to 125%. 
                    It should be set to 100% (WARNING: The server did not provide any stacktrace information)
                    */

                    // var exec = require('child_process').exec;
                    // exec('start "" "c:\\Program Files\\Internet Explorer\\iexplore.exe" "http://google.com/"');
                    mainWindow.closeDevTools();
                }
            }]
        }]
    }];
    if (process.platform == 'darwin') {
        var name = require('electron').app.getName();
        application_menu.unshift({
            label: name,
            submenu: [{
                label: 'About ' + name,
                role: 'about'
            }, {
                type: 'separator'
            }, {
                label: 'Services',
                role: 'services',
                submenu: []
            }, {
                type: 'separator'
            }, {
                label: 'Hide ' + name,
                accelerator: 'Command+H',
                role: 'hide'
            }, {
                label: 'Hide Others',
                accelerator: 'Command+Shift+H',
                role: 'hideothers'
            }, {
                label: 'Show All',
                role: 'unhide'
            }, {
                type: 'separator'
            }, {
                label: 'Quit',
                accelerator: 'Command+Q',
                click: function() {
                    app.quit();
                }
            }, ]
        });
    }

    menu = Menu.buildFromTemplate(application_menu);
    Menu.setApplicationMenu(menu);

    // Emitted when the window is closed.
    mainWindow.on('closed', function() {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        mainWindow = null;
    });
});