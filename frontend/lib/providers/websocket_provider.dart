import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketNotifier extends StateNotifier<WebSocketChannel?> {
  WebsocketNotifier() : super(null);

  void connectToWebSocketServer(String uri) {
    state = WebSocketChannel.connect(Uri.parse(uri));
  }
}

final websocketProvider =
    StateNotifierProvider<WebsocketNotifier, WebSocketChannel?>(
  (ref) => WebsocketNotifier(),
);
