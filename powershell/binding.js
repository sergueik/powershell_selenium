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

return findBindings(binding, exactMatch, using, rootSelector);