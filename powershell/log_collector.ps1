# https://groups.google.com/forum/#!topic/selenium-users/zzmn4k3B9GA

$script = @"

var logs= [
];
(function () {
  var originallog= console.log;
  console.log = function () {
    logs.push(arguments);
    originallog.apply(this, arguments);
  }
}) ();

"@
