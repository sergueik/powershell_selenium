(function () {
    'use strict';

    angular.module('app', [])
        .controller('demo', ['$scope', 'chat', demo]);

    function demo($scope, chat) {
        var vm = this;

        // Bindable properties and functions are placed on vm.
        vm.activate = activate;
        vm.messages = [];
        vm.name = '';
        vm.newContent = '';
        vm.sendMessage = sendMessage;

        activate();

        function activate() {
            toastr.options.positionClass = 'toast-bottom-right';
            onReceiveMessage();
            onStartConnection();
        }

        function onStartConnection() {
            $scope.$on('CHAT_CONNECTION_STARTED', function (event, data) {
                toastr.success('SignalR connection started');
            });
        }

        function onReceiveMessage() {
            $scope.$on('CHAT_MESSAGE_RECEIVED', function (event, data) {
                toastr.info(data.content, 'New Message from ' + data.name);
                vm.messages.push(data);
            });
        }

        function sendMessage() {
            if (!vm.newContent) return;
            chat.sendMessage(vm.name, vm.newContent);
            vm.newContent = '';
        }
    }
})();


//(function () {
//    'use strict';

//    angular.module('app', [])
//        .controller('demo', ['$scope', 'chat', demo]);

//    function demo($scope, chat) {
//        var vm = this;
//        // Declare a proxy to reference the hub.
//        var chat = $.connection.chatHub;

//        // Bindable properties and functions are placed on vm.
//        vm.activate = activate;
//        vm.messages = [];
//        vm.name = '';
//        vm.newContent = '';
//        vm.sendMessage = sendMessage;

//        activate();

//        function activate() {
//            toastr.options.positionClass = 'toast-bottom-right';
//            onReceiveMessage();
//            startConnection();
//        }

//        function startConnection() {
//            $.connection.hub.start().done(function () {
//                toastr.success('SignalR connection started');
//            });
//        }

//        function onReceiveMessage() {
//            // Create a function that the hub can call to broadcast messages.
//            chat.client.broadcastMessage = function (name, message) {
//                toastr.info(message, 'New Message from ' + name);
//                vm.messages.push({ name: name, content: message });
//                $scope.$apply();
//            };
//        }

//        function sendMessage() {
//            if (!vm.newContent) return;

//            // Call the Send method on the hub.
//            chat.server.send(vm.name, vm.newContent);
//            vm.newContent = '';
//        }
//    }
//})();
