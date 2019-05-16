/**
 * Returns hash of all attributes of an DOM element
 *
 * arguments[0] {Element} The event target.
 */
// origin: https://stackoverflow.com/questions/27307131/selenium-webdriver-how-do-i-find-all-of-an-elements-attributes
// see also: getStyle
// http://www.htmlgoodies.com/html5/css/referencing-css3-properties-using-javascript.html#fbid=88eQV8NzD6Q 
getAttributes = function(element) {
    var items = {};
    for (index = 0; index < element.attributes.length; ++index) {
        items[element.attributes[index].name] = element.attributes[index].value
    };
    return JSON.stringify(items);
}

var element = arguments[0];
return getAttributes(element);
