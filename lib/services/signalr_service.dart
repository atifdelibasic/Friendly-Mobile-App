import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late HubConnection _hubConnection;

  Future<void> connect(String url, String accessToken) async {

  final hubConnectionBuilder = HubConnectionBuilder().withUrl(
    url,
    options: HttpConnectionOptions(
      accessTokenFactory: () async {
        // Complete the Future when accessToken is obtained
        return accessToken;
      },
    ),
  );

    print("uredno");

    _hubConnection = hubConnectionBuilder.build();

    await _hubConnection.start();
  }

  Future<void> sendMessage(String message) async {
  try {
    if (_hubConnection != null && _hubConnection.state == HubConnectionState.Connected) {
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

  void onReceiveMessage(Function( String message, bool me)) {
    _hubConnection.on('SendMessageAsync', (arguments) {
      
    });
  }

  Future<void> disconnect() async {
    await _hubConnection.stop();
  }
}
