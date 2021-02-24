/**
 * Tests if an ngRepeat matches a repeater
 *
 * @param {string} ngRepeat The ngRepeat to test
 * @param {string} repeater The repeater to test against
 * @param {boolean} exact If the ngRepeat expression needs to match the whole
 *   repeater (not counting any `track by ...` modifier) or if it just needs to
 *   match a substring
 * @return {boolean} If the ngRepeat matched the repeater
 */
var repeaterMatch = function(ngRepeat, repeater, exact) {
  if (exact) {
    return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
    split('=')[0].trim() == repeater;
  } else {
    return ngRepeat.indexOf(repeater) != -1;
  }
}

/**
* Find the elements in a column of an ng-repeat.
*
* @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
* @param {boolean} exact Whether the repeater needs to be matched exactly
* @param {string} binding The column binding, e.g. '{{cat.name}}'.
* @param {Element} using The scope of the search.
* @param {string} rootSelector The selector to use for the root app element.
*
* @return {Array.WebElement} The elements in the column.
*/


var findRepeaterColumn = function(repeater, exact, binding, using, rootSelector) {
    var matches = [];
    var root = document.querySelector(rootSelector || 'body');
    using = using || document;
    var rows = [];
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var attr = prefixes[p] + 'repeat';
        var repeatElems = using.querySelectorAll('[' + attr + ']');
        attr = attr.replace(/\\/g, '');
        for (var i = 0; i < repeatElems.length; ++i) {
            if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
                rows.push(repeatElems[i]);
            }
        }
    }
    /* multiRows is an array of arrays, where each inner array contains
    one row of elements. */
    var multiRows = [];
    for (var p = 0; p < prefixes.length; ++p) {
        var attr = prefixes[p] + 'repeat-start';
        var repeatElems = using.querySelectorAll('[' + attr + ']');
        attr = attr.replace(/\\/g, '');
        for (var i = 0; i < repeatElems.length; ++i) {
            if (repeaterMatch(repeatElems[i].getAttribute(attr), repeater, exact)) {
                var elem = repeatElems[i];
                var row = [];
                while (elem.nodeType != 8 || (elem.nodeValue &&
                        !repeaterMatch(elem.nodeValue, repeater))) {
                    if (elem.nodeType == 1) {
                        row.push(elem);
                    }
                    elem = elem.nextSibling;
                }
                multiRows.push(row);
            }
        }
    }
    var bindings = [];
    for (var i = 0; i < rows.length; ++i) {
        if (angular.getTestability) {
            matches.push.apply(
                matches,
                angular.getTestability(root).findBindings(rows[i], binding));
        } else {
            if (rows[i].className.indexOf('ng-binding') != -1) {
                bindings.push(rows[i]);
            }
            var childBindings = rows[i].getElementsByClassName('ng-binding');
            for (var k = 0; k < childBindings.length; ++k) {
                bindings.push(childBindings[k]);
            }
        }
    }
    for (var i = 0; i < multiRows.length; ++i) {
        for (var j = 0; j < multiRows[i].length; ++j) {
            if (angular.getTestability) {
                matches.push.apply(
                    matches,
                    angular.getTestability(root).findBindings(multiRows[i][j], binding));
            } else {
                var elem = multiRows[i][j];
                if (elem.className.indexOf('ng-binding') != -1) {
                    bindings.push(elem);
                }
                var childBindings = elem.getElementsByClassName('ng-binding');
                for (var k = 0; k < childBindings.length; ++k) {
                    bindings.push(childBindings[k]);
                }
            }
        }
    }
    for (var j = 0; j < bindings.length; ++j) {
        var dataBinding = angular.element(bindings[j]).data('$binding');
        if (dataBinding) {
            var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
            if (bindingName.indexOf(binding) != -1) {
                matches.push(bindings[j]);
            }
        }
    }
    return matches;
};

var using = arguments[0] || document;
var repeater = arguments[1];
var binding = arguments[2];
var exact = false;
var rootSelector = null;
return findRepeaterColumn(repeater, exact, binding, using, rootSelector);