package com.mycompany.app.utils

/**
 * File:  ConsoleWaiter.groovy
 */

import groovy.lang.Binding;
import groovy.ui.Console;

/**
 * Provides a wrapper for the console.
 *
 * Based on source by John Green
 * Adapted from:  http://www.oehive.org/files/ConsoleWaiter.groovy
 * Released under the Eclipse Public License
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * I added methods to allow use from Java.
 *
 * The run() method launches the console and causes this thread
 * to sleep until the console's window is closed.
 * Allows easy interaction with the objects alive at a given
 * point in an application's execution, like in a debugger
 * session.
 *
 * Example 1:
<pre> * new ConsoleWaiter().run()
 *</pre>
 *

 * Example 2:
<pre> * def waiter = new ConsoleWaiter()
 * waiter.console.setVariable("node", node)
 * waiter.run()
 *</pre>
 */
class ConsoleWaiter {
 Console console
 Object source
 boolean done = false;

 /** */
 public ConsoleWaiter(Console inConsole){
    this.console = inConsole
 }

 /** */
 public ConsoleWaiter(Object source){
    console =
    new Console(getClass().classLoader,
    new Binding())
    this.source = source
    console.setVariable("source", source)
 }

 /** */
 public void setVar(String key, Object value){
    console.setVariable(key, value)
 }

 /** 	 */
 public void setVar(String key, List values){
    console.setVariable(key, values)
 }

 /** 	 */
 public void setVar(String key, Object[] values){
    console.setVariable(key, values)
 }

 /** 	 */
 public void run() {
    console.run()
    // I'm a little surprised that this exit() can be private.
    console.frame.windowClosing = this.&exit
    console.frame.windowClosed = this.&exit
    while (!done) {
       sleep 1000
    }
 }

 /** 	 */
 public boolean isDone(){
    return done;
 }

 /** 	 */
 public void exit(EventObject evt = null) {
    done = true
 }

 /** 	 */
 public Console getConsole(){
    return console;
 }
}

