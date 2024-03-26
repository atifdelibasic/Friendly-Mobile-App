import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';


class SignalRService {
  late HubConnection _hubConnection;

  Future<void> connect(String url, String accessToken) async {

  _hubConnection = HubConnectionBuilder().withUrl(
    url,
    options: HttpConnectionOptions(
      accessTokenFactory: () async {
        // Complete the Future when accessToken is obtained
        return accessToken;
      },
    ),
  )
  .withHubProtocol(MessagePackHubProtocol())
          .withAutomaticReconnect()
          .build();

    print("uredno");

    await _hubConnection.start();
    print("connection started");
  }

  Future<void> sendMessage(String message) async {
  try {
    if ( _hubConnection.state == HubConnectionState.Connected) {
      final result = await _hubConnection.invoke('SendMessageAsync', args: [message]);
      // Handle the result or any other logic here
    } else {
      print('Error: _hubConnection is not initialized or not connected.');
    }
  } catch (e, stackTrace) {
    print('Error during invoke: $e');
    print('StackTrace: $stackTrace');
  }
}

  void onReceiveMessage(Function(String message, bool isMe) callback) {
    _hubConnection.on('SendMessageAsync', (arguments) {

      if(arguments == null) {
        return;
      }

      callback(arguments[0].toString(), arguments[1].toString().toLowerCase() == "true");
    });
  }

  Future<void> disconnect() async {
    await _hubConnection.stop();
  }
}
