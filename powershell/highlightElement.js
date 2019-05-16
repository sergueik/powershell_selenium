// origin: https://github.com/angular/blocking-proxy/blob/master/lib/client_scripts/highlight.js
/**
 * Creates a floating translucent div at the specified location in order to highlight a particular element.
 */
highlight_create = function(top, left, width, height) {
  // console.log('Highlighting at ', top, left, width, height);
  var el = document.createElement('div');
  el.id = 'BP_ELEMENT_HIGHLIGHT__';
  document.body.appendChild(el);
  el.style['position'] = 'absolute';
  el.style['background-color'] = 'lightblue';
  el.style['opacity'] = '0.7';
  el.style['top'] = top + 'px';
  el.style['left'] = left + 'px';
  el.style['width'] = width + 'px';
  el.style['height'] = height + 'px';
};

/**
 * Removes the highlight from the DOM
 */
highlight_remove = function() {
  var el = document.getElementById('BP_ELEMENT_HIGHLIGHT__');
  if (el) {
    el.parentElement.removeChild(el);
  }
};

// origin:  3.5.8_0\content\targetSelecter.js
// Modified in tools.js from selenium-IDE
highlightElement = function(element) {
  var r = element.getBoundingClientRect();
  var style = "pointer-events: none; position: absolute; box-shadow: 0 0 0 1px black; outline: 1px dashed white; outline-offset: -1px; background-color: rgba(250,250,128,0.4); z-index: 100;";
  var pos = "top:" + (r.top + window.scrollY) + "px; left:" + (r.left + window.scrollX) + "px; width:" + r.width + "px; height:" + r.height + "px;";
  var div = window.document.createElement("div");
  div.id = '__ELEMENT_HIGHLIGHT__';
  div.setAttribute("style", "display: none;");
  doc.body.insertBefore(div, doc.body.firstChild);
  div.setAttribute("style", style + pos);
};

unHighlightElement = function(element) {
  var div = document.getElementById('__ELEMENT_HIGHLIGHT__');
  div.setAttribute("style", "display: none;");
};
