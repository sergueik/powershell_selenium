(function () {
    'use strict';

    angular.module('app')
        .factory('chat', ['$rootScope', chat]);

    function chat($rootScope) {
        var chatHub = $.connection.chatHub;
        
        var service = {
            sendMessage: sendMessage
        };

        init();

        return service;

        function init() {
            startConnection();
            onReceiveMessage();
        }

        function startConnection() {
            $.connection.hub.start().done(function () {
                $rootScope.$broadcast('CHAT_CONNECTION_STARTED', { data: 'Started' });
            });
        }

        function onReceiveMessage() {
            // Create a function that the hub can call to broadcast messages.
            chatHub.client.broadcastMessage = function (name, message) {
                var data = { name: name, content: message };
                $rootScope.$broadcast('CHAT_MESSAGE_RECEIVED', data);
                $rootScope.$apply();
            };
        }

        function sendMessage(fromName, fromContent) {
            if (!fromContent) return;
            // Call the Send method on the hub.
            chatHub.server.send(fromName, fromContent);
        }
    }
})();