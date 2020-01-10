﻿// From https://github.com/angular/protractor/blob/master/lib/clientsidescripts.js

namespace ShadowDriver
{
    /**
     * All scripts to be run on the client via ExecuteAsyncScript or
     * ExecuteScript should be put here. These scripts are transmitted over
     * the wire using their toString representation, and cannot reference
     * external variables. They can, however use the array passed in to
     * arguments. Instead of params, all functions on clientSideScripts
     * should list the arguments array they expect.
     */
    internal class ClientSideScripts
    {
        /**
         * Wait until Angular has finished rendering and has
         * no outstanding $http calls before continuing.
         *
         * arguments[0] {string} The selector housing an ng-app
         * arguments[1] {function} callback
         */
        public const string WaitForAngular = @"
        
        var waitForAngular = function(rootSelector, callback) {
            var el = document.querySelector(rootSelector);
            try {
                if (window.getAngularTestability) {
                    window.getAngularTestability(el).whenStable(callback);
                    return;
                }
                if (!window.angular) {
                    throw new Error('window.angular is undefined. This could be either ' +
                        'because this is a non-angular page or because your test involves ' +
                        'client-side navigation, which can interfere with ShadowDriver\'s ' +
                        'bootstrapping. See http://git.io/v4gXM for details');
                }
                if (angular.getTestability) {
                    angular.getTestability(el).whenStable(callback);
                } else {
                    if (!angular.element(el).injector()) {
                        throw new Error('root element (' + rootSelector + ') has no injector.' +
                            ' this may mean it is not inside ng-app.');
                    }
                    angular.element(el).injector().get('$browser').
                    notifyWhenNoOutstandingRequests(callback);
                }
            } catch (err) {
                callback(err.message);
            }
        };

var rootSelector = arguments[0];
var callback = arguments[1];

waitForAngular(rootSelector, callback);

";
        /**
         * Wait until Angular has finished rendering and has
         * no outstanding $http calls before continuing.
         *
         * arguments[0] {function} callback
         */
        public const string WaitForAllAngular2 = @"
var waitForAllAngular2 = function(callback) {
    try {
        var testabilities = window.getAllAngularTestabilities();
        var count = testabilities.length;
        var decrement = function() {
            count--;
            if (count === 0) {
                callback();
            }
        };
        testabilities.forEach(function(testability) {
            testability.whenStable(decrement);
        });
    } catch (err) {
        callback(err.message);
    }
};
var callback = arguments[0];
waitForAllAngular2(callback);
";

        /**
         * Tests whether the angular global variable is present on a page. 
         * Retries in case the page is just loading slowly.
         *
         * arguments[0] {string} none.
         */
        public const string TestForAngular = @"
var attempts = arguments[0];
var callback = arguments[arguments.length - 1];
var testForAngular = function(attempts) {
    if (window.getAllAngularTestabilities) {
        callback(2);
    } else if (window.angular && window.angular.resumeBootstrap) {
        callback(1);
    } else if (attempts < 1) {
        callback(0);
    } else {
        window.setTimeout(function() {
            testForAngular(attempts - 1)
        }, 1000);
    }
};
testForAngular(attempts);";
        /**
         * Continue to bootstrap Angular. 
         * 
         * arguments[0] {array} The module names to load.
         */
        public const string ResumeAngularBootstrap = "angular.resumeBootstrap(arguments[0].length ? arguments[0].split(',') : []);";


        /**
 * Return the current location using $location.url().
 *
 * arguments[0] {string} The selector housing an ng-app
 */
        public const string GetLocation = @"
var getLocation = function(selector) {
    var el = document.querySelector(selector || 'body');
if (angular.getTestability) {
    return angular.getTestability(el).getLocation();
}
return angular.element(el).injector().get('$location').url();
}
var selector = arguments[0];
return getLocation(selector);
";

        /**
         * Return the current url using $location.absUrl().
         * 
         * arguments[0] {string} The selector housing an ng-app
         */
        public const string GetLocationAbsUrl = "var el = document.querySelector(arguments[0]);return angular.element(el).injector().get('$location').absUrl();";

        /**
         * Evaluate an Angular expression in the context of a given element.
         *
         * arguments[0] {Element} The element in whose scope to evaluate.
         * arguments[1] {string} The expression to evaluate.
         *
         * @return {?Object} The result of the evaluation.
         */
        public const string Evaluate = "return angular.element(arguments[0]).scope().$eval(arguments[1]);";

        /**
		 * Browse to another page using in-page navigation.
		 *
		 * arguments[0]  {string} selector The selector housing an ng-app
		 * arguments[1]{string} url In page URL using the same syntax as $location.url(), e.g.
		 * 
		 */
        public const string SetLocation = @"
var setLocation = function(selector, url) {

    var el = document.querySelector(selector || 'body');
    if (angular.getTestability) {
        return angular.getTestability(el).
        setLocation(url);
    }
    var $injector = angular.element(el).injector();
    var $location = $injector.get('$location');
    var $rootScope = $injector.get('$rootScope');
    if (url !== $location.url()) {
        $location.url(url);
        $rootScope.$digest();
    }
};
var selector = arguments[0];
var url = arguments[1];

setLocation(selector, url);";

        #region Locators

        /**
         * Find a list of elements in the page by their angular binding.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The binding, e.g. {{cat.name}}.
         * arguments[2] {boolean} Whether the binding needs to be matched exactly.
         * arguments[3] {string} The selector to use for the root app element.
         *
         * @return {Array.WebElement} The elements containing the binding.
         */

        public const string FindBindings = @"
var findBindings = function(binding, exactMatch, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || document;
    if (angular.getTestability) {
        return angular.getTestability(root).
        findBindings(using, binding, exactMatch);
    }
    var bindings = using.getElementsByClassName('ng-binding');
    var matches = [];
    for (var i = 0; i < bindings.length; ++i) {
        var dataBinding = angular.element(bindings[i]).data('$binding');
        if (dataBinding) {
            var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
            if (exactMatch) {
                var matcher = new RegExp('({|\\s|^|\\|)' +
                    /* See http://stackoverflow.com/q/3561711 */
                    binding.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&') +
                    '(}|\\s|$|\\|)');
                if (matcher.test(bindingName)) {
                    matches.push(bindings[i]);
                }
            } else {
                if (bindingName.indexOf(binding) != -1) {
                    matches.push(bindings[i]);
                }
            }
        }
    }
    return matches; /* Return the whole array for webdriver.findElements. */
};

var using = arguments[0] || document;
var binding = arguments[1];
var rootSelector = arguments[2];

var exactMatch = arguments[3];
if (typeof exactMatch === 'undefined') {
    exactMatch = true;
}

return findBindings(binding, exactMatch, using, rootSelector);";


        /**
         * Find elements by model name.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The model name.
         *
         * @return {Array.WebElement} The matching input elements.
         */
        public const string FindModel = @"
var findByModel = function(model, using, rootSelector) {
    var root = document.querySelector(rootSelector || 'body');
    using = using || '[ng-app]';
    using = using || document;
    if (angular.getTestability) {
        return angular.getTestability(root).
        findModels(using, model, true);
    }
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'model=""' + model + '""]';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};
var using = arguments[0] || document;
var model = arguments[1];
var rootSelector = arguments[2];
return findByModel(model, using, rootSelector);
";

        /**
          * Find selected option elements by model name.
          *
          * arguments[0] {Element} The scope of the search.
          * arguments[1] {string} The model name.
          *
          * @return {Array.WebElement} The matching select elements.
          */
        public const string FindSelectedOption = @"
var findSelectedOption = function(model, using ) {
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = 'select[' + prefixes[p] + 'model=""' + model + '""] option:checked';
        var inputs = using.querySelectorAll(selector);
        if (inputs.length) {
            return inputs;
        }
    }
};
var using = arguments[0] || document;
var model = arguments[1];
return findSelectedOption(model, using);
";
        /**
         * Find buttons by textual content.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The exact text to match.
         *
         * @return {Array.Element} The matching elements.
         */

        public const string FindByButtonText = @"
var findByButtonText = function(searchText, using) {
    using = using || document;
    var elements = using.querySelectorAll('button, input[type=""button""], input[type=""submit""]');
    var matches = [];
    for (var i = 0; i < elements.length; ++i) {
        var element = elements[i];
        var elementText;
        if (element.tagName.toLowerCase() == 'button') {
            elementText = element.textContent || element.innerText || '';
        } else {
            elementText = element.value;
        }
        if (elementText.trim() === searchText) {
            matches.push(element);
        }
    }
    return matches;
};
var using = arguments[0] || document;
var searchText = arguments[1];
return findByButtonText(searchText, using);";

        /**
         * Shadow DOOM library
         * @return {Array.WebElement} The matching select elements.
         */

        public const string FindShadowDOMElements = @"
        
var getShadowElement = function getShadowElement(object, selector) {
    return object.shadowRoot.querySelector(selector);
};

var getAllShadowElement = function getAllShadowElement(object, selector) {
    return object.shadowRoot.querySelectorAll(selector);
};

var getAttribute = function getAttribute(object, attribute) {
    return object.getAttribute(attribute);
};

var isVisible = function isVisible(object) {
    var visible = object.offsetWidth;
    if (visible > 0) {
        return true;
    } else {
        return false;
    }
};

var scrollTo = function scrollTo(object) {
    object.scrollIntoView({
        block: 'center',
        inline: 'nearest'
    });
};

var getParentElement = function getParentElement(object) {
    if (object.parentNode.nodeName == '#document-fragment') {
        return object.parentNode.host;
    } else if (object.nodeName == '#document-fragment') {
        return object.host;
    } else {
        return object.parentElement;
    }
};

var getChildElements = function getChildElements(object) {
    if (object.nodeName == '#document-fragment') {
        return object.children;
    } else {
        return object.childNodes;
    }
};

var getSiblingElements = function getSiblingElements(object) {
    if (object.nodeName == '#document-fragment') {
        return object.host.children;
    } else {
        return object.siblings();
    }
};

var getSiblingElement = function getSiblingElement(object, selector) {
    if (object.nodeName == '#document-fragment') {
        return object.host.querySelector(selector);
    } else {
        return object.parentElement.querySelector(selector);
    }
};

var getNextSiblingElement = function getNextSiblingElement(object) {
    if (object.nodeName == '#document-fragment') {
        return object.host.firstElementChild.nextElementSibling;
    } else {
        return object.nextElementSibling;
    }
};

var getPreviousSiblingElement = function getPreviousSiblingElement(object) {
    if (object.nodeName == '#document-fragment') {
        return null;
    } else {
        return object.previousElementSibling;
    }
};

var isChecked = function isChecked(object) {
    return object.checked;
};

var isDisabled = function isDisabled(object) {
    return object.disabled;
};

var findCheckboxWithLabel = function findCheckboxWithLabel(label, root = document) {
    if (root.nodeName == 'PAPER-CHECKBOX') {
        if (root.childNodes[0].data.trimStart().trimEnd() == label) {
            return root;
        }
    } else {
        let all_checkbox = getAllObject('paper-checkbox', root);
        for (let checkbox of all_checkbox) {
            if (checkbox.childNodes[0].data.trimStart().trimEnd() == label) {
                return checkbox;
            }
        }
    }
};

var findRadioWithLabel = function findRadioWithLabel(label, root = document) {
    if (root.nodeName == 'PAPER-RADIO-BUTTON') {
        if (root.childNodes[0].data.trimStart().trimEnd() == label) {
            return root;
        }
    } else {
        let all_radio = getAllObject('paper-radio-button', root);
        for (let radio of all_radio) {
            if (radio.childNodes[0].data.trimStart().trimEnd() == label) {
                return radio;
            }
        }
    }
};

var selectCheckbox = function selectCheckbox(label, root = document) {
    let checkbox = findCheckboxWithLabel(label, root);
    if (!checkbox.checked) {
        checbox.click();
    }
};

var selectRadio = function selectRadio(label, root = document) {
    let radio = findCheckboxWithLabel(label, root);
    if (!radio.checked) {
        radio.click();
    }
};

var selectDropdown = function selectDropdown(label, root = document) {
    if (root.nodeName == 'PAPER-LISTBOX') {
        root.select(label);
    } else {
        let listbox = getAllObject('paper-listbox', root);
        listbox.select(label);
    }
};

var querySelectorAllDeep = function querySelectorAllDeep(selector, root) {
    if (root == undefined) {
        return _querySelectorDeep(selector, true, document);
    } else {
        return _querySelectorDeep(selector, true, root);
    }
};

var querySelectorDeep = function querySelectorDeep(selector, root) {
    if (root == undefined) {
        return _querySelectorDeep(selector, false, document);
    } else {
        return _querySelectorDeep(selector, false, root);
    }
};

var getObject = function getObject(selector, root = document) {
    const multiLevelSelectors = splitByCharacterUnlessQuoted(selector, '>');
    if (multiLevelSelectors.length == 1) {
        return querySelectorDeep(multiLevelSelectors[0], root);
    } else if (multiLevelSelectors.length == 2) {
        return querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root);
    } else if (multiLevelSelectors.length == 3) {
        return querySelectorDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root));
    } else if (multiLevelSelectors.length == 4) {
        return querySelectorDeep(multiLevelSelectors[3], querySelectorDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root)));
    } else if (multiLevelSelectors.length == 5) {
        return querySelectorDeep(multiLevelSelectors[4], querySelectorDeep(multiLevelSelectors[3], querySelectorDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root))));
    }
};

var getAllObject = function getAllObject(selector, root = document) {
    const multiLevelSelectors = splitByCharacterUnlessQuoted(selector, '>');
    if (multiLevelSelectors.length == 1) {
        return querySelectorAllDeep(multiLevelSelectors[0], root);
    } else if (multiLevelSelectors.length == 2) {
        return querySelectorAllDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root);
    } else if (multiLevelSelectors.length == 3) {
        return querySelectorAllDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root));
    } else if (multiLevelSelectors.length == 4) {
        return querySelectorAllDeep(multiLevelSelectors[3], querySelectorDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root)));
    } else if (multiLevelSelectors.length == 5) {
        return querySelectorAllDeep(multiLevelSelectors[4], querySelectorDeep(multiLevelSelectors[3], querySelectorDeep(multiLevelSelectors[2], querySelectorDeep(multiLevelSelectors[1], querySelectorDeep(multiLevelSelectors[0]).root))));
    }

};

function _querySelectorDeep(selector, findMany, root) {
    let lightElement = root.querySelector(selector);

    if (document.head.createShadowRoot || document.head.attachShadow) {
        if (!findMany && lightElement) {
            return lightElement;
        }

        const selectionsToMake = splitByCharacterUnlessQuoted(selector, ',');

        return selectionsToMake.reduce((acc, minimalSelector) => {
            if (!findMany && acc) {
                return acc;
            }
            const splitSelector = splitByCharacterUnlessQuoted(minimalSelector
                    .replace(/^\s+/g, '')
                    .replace(/\s*([>+~]+)\s*/g, '$1'), ' ')
                .filter((entry) => !!entry);
            const possibleElementsIndex = splitSelector.length - 1;
            const possibleElements = collectAllElementsDeep(splitSelector[possibleElementsIndex], root);
            const findElements = findMatchingElement(splitSelector, possibleElementsIndex, root);
            if (findMany) {
                acc = acc.concat(possibleElements.filter(findElements));
                return acc;
            } else {
                acc = possibleElements.find(findElements);
                return acc;
            }
        }, findMany ? [] : null);


    } else {
        if (!findMany) {
            return lightElement;
        } else {
            return root.querySelectorAll(selector);
        }
    }

}

function findMatchingElement(splitSelector, possibleElementsIndex, root) {
    return (element) => {
        let position = possibleElementsIndex;
        let parent = element;
        let foundElement = false;
        while (parent) {
            const foundMatch = parent.matches(splitSelector[position]);
            if (foundMatch && position === 0) {
                foundElement = true;
                break;
            }
            if (foundMatch) {
                position--;
            }
            parent = findParentOrHost(parent, root);
        }
        return foundElement;
    };

}

function splitByCharacterUnlessQuoted(selector, character) {
    return selector.match(/\\\\?.|^$/g).reduce((p, c) => {
        if (c === '""' && !p.sQuote) {
            p.quote ^= 1;
            p.a[p.a.length - 1] += c;
        } else if (c === '\\'' && !p.quote) {
            p.sQuote ^= 1;
            p.a[p.a.length - 1] += c;

        } else if (!p.quote && !p.sQuote && c === character) {
            p.a.push('');
        } else {
            p.a[p.a.length - 1] += c;
        }
        return p;
    }, {
        a: ['']
    }).a;
}


function findParentOrHost(element, root) {
    const parentNode = element.parentNode;
    return (parentNode && parentNode.host && parentNode.nodeType === 11) ? parentNode.host : parentNode === root ? null : parentNode;
}


function collectAllElementsDeep(selector = null, root) {
    const allElements = [];

    const findAllElements = function(nodes) {
        for (let i = 0, el; el = nodes[i]; ++i) {
            allElements.push(el);
            if (el.shadowRoot) {
                findAllElements(el.shadowRoot.querySelectorAll('*'));
            }
        }
    };

    if (root.shadowRoot != null) {
        findAllElements(root.shadowRoot.querySelectorAll('*'));
    }

    findAllElements(root.querySelectorAll('*'));

    return selector ? allElements.filter(el => el.matches(selector)) : allElements;
}
        ";
        public const string FindSelectedRepeaterOption = @"

var findSelectedRepeaterOption = function(repeater, using) {
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = 'option[' + prefixes[p] + 'repeat=""' + repeater + '""]:checked';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};
var using = arguments[0] || document;
var repeater = arguments[1];
return findSelectedRepeaterOption(repeater, using);

";

        /**
         * Find buttons by textual content.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The partial text to match.
         *
         * @return {Array.Element} The matching elements.
         */

        public const string FindByPartialButtonText = @"
var findByPartialButtonText = function(searchText, using) {
    using = using || document;
    var elements = using.querySelectorAll('button, input[type=""button""], input[type=""submit""]');
    var matches = [];
    for (var i = 0; i < elements.length; ++i) {
        var element = elements[i];
        var elementText;
        if (element.tagName.toLowerCase() == 'button') {
            elementText = element.textContent || element.innerText || '';
        } else {
            elementText = element.value;
        }
        if (elementText.indexOf(searchText) > -1) {
            matches.push(element);
        }
    }
    return matches;
};
var using = arguments[0] || document;
var searchText = arguments[1];
return findByPartialButtonText(searchText, using);";

        /**
         * Find buttons by textual content.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The exact text to match.
         * arguments[2] {string} The css selector to match.
         *
         * @return {Array.Element} The matching elements.
         */

        public const string FindByCssContainingText = @"
var using = arguments[0] || document;
var searchText = arguments[1];
var cssSelector = arguments[2];
var elements = using.querySelectorAll(cssSelector);
var matches = [];
for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText = element.textContent || element.innerText || '';
    if (elementText.indexOf(searchText) > -1) {
        matches.push(element);
    }
}
return matches;
";

        /**
         * Find elements by options.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The descriptor for the option
         * (i.e. fruit for fruit in fruits).
         *
         * @return {Array.WebElement} The matching elements.
         */

        public const string FindByOptions = @"
var findByOptions = function(options, using) {
    using = using || document;
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var selector = '[' + prefixes[p] + 'options=""' + options + '""] option';
        var elements = using.querySelectorAll(selector);
        if (elements.length) {
            return elements;
        }
    }
};

var using = arguments[0] || document;
var options = arguments[1];
return findByOptions(options, using);";


        /**
         * Find all rows of an ng-repeat.
         *
         * arguments[0] {Element} The scope of the search.
         * arguments[1] {string} The text of the repeater, e.g. 'cat in cats'.
         *
         * @return {Array.WebElement} All rows of the repeater.
         */
        public const string FindAllRepeaterRows = @"
var findAllRepeaterRows = function(using, repeater) {
    var rows = [];
    var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\:'];
    for (var p = 0; p < prefixes.length; ++p) {
        var attr = prefixes[p] + 'repeat';
        var repeatElems = using.querySelectorAll('[' + attr + ']');
        attr = attr.replace(/\\/g, '');
        for (var i = 0; i < repeatElems.length; ++i) {
            if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
                rows.push(repeatElems[i]);
            }
        }
    }
    for (var p = 0; p < prefixes.length; ++p) {
        var attr = prefixes[p] + 'repeat-start';
        var repeatElems = using.querySelectorAll('[' + attr + ']');
        attr = attr.replace(/\\/g, '');
        for (var i = 0; i < repeatElems.length; ++i) {
            if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
                var elem = repeatElems[i];
                while (elem.nodeType != 8 ||
                    !(elem.nodeValue.indexOf(repeater) != -1)) {
                    if (elem.nodeType == 1) {
                        rows.push(elem);
                    }
                    elem = elem.nextSibling;
                }
            }
        }
    }
    return rows;
};
var using = arguments[0] || document;
var repeater = arguments[1];
return findAllRepeaterRows(using, repeater);";

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


        public const string FindRepeaterColumn = @"
var repeaterMatch = function(ngRepeat, repeater, exact) {
    if (exact) {
        return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
        split('=')[0].trim() == repeater;
    } else {
        return ngRepeat.indexOf(repeater) != -1;
    }
}

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
var rootSelector = arguments[3];
return findRepeaterColumn(repeater, exact, binding, using, rootSelector);";

        /**
		 * Find an element within an ng-repeat by its row and column.
		 *
		 * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
		 * @param {boolean} exact Whether the repeater needs to be matched exactly
		 * @param {number} index The row index.
		 * @param {string} binding The column binding, e.g. '{{cat.name}}'.
		 * @param {Element} using The scope of the search.
		 * @param {string} rootSelector The selector to use for the root app element.
		 *
		 * @return {Array.WebElement} The element in an array.
		 */


        public const string FindRepeaterElement = @"
        
        function repeaterMatch(ngRepeat, repeater, exact) {
  if (exact) {
    return ngRepeat.split(' track by ')[0].split(' as ')[0].split('|')[0].
        split('=')[0].trim() == repeater;
  } else {
    return ngRepeat.indexOf(repeater) != -1;
  }
}

var findRepeaterElement = function(repeater, exact, index, binding, using, rootSelector) {
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
  var row = rows[index];
  var multiRow = multiRows[index];
  var bindings = [];
  if (row) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(root).findBindings(row, binding));
    } else {
      if (row.className.indexOf('ng-binding') != -1) {
        bindings.push(row);
      }
      var childBindings = row.getElementsByClassName('ng-binding');
      for (var i = 0; i < childBindings.length; ++i) {
        bindings.push(childBindings[i]);
      }
    }
  }
  if (multiRow) {
    for (var i = 0; i < multiRow.length; ++i) {
      var rowElem = multiRow[i];
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(root).findBindings(rowElem, binding));
      } else {
        if (rowElem.className.indexOf('ng-binding') != -1) {
          bindings.push(rowElem);
        }
        var childBindings = rowElem.getElementsByClassName('ng-binding');
        for (var j = 0; j < childBindings.length; ++j) {
          bindings.push(childBindings[j]);
        }
      }
    }
  }
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[i]);
      }
    }
  }
  return matches;
}


var using = arguments[0] || document;
var repeater = arguments[1];
var index = arguments[2];
var binding = arguments[3];
var exact = false;
var rootSelector = null; // TODO
return findRepeaterElement(repeater, exact, index, binding, using, rootSelector);";
        #endregion
    }
}