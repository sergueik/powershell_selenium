 /**
  * Evaluate an Angular expression in the context of a given element.
  *
  * arguments[0] {Element} The element in whose scope to evaluate.
  * arguments[1] {string} The expression to evaluate.
  *
  * @return {?Object} The result of the evaluation.
  */
 var element = arguments[0];
 var expression = arguments[1];
 return angular.element(element).scope().$eval(expression);