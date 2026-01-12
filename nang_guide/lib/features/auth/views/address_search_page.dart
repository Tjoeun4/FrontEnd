import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({Key? key}) : super(key: key);

  @override
  _AddressSearchPageState createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  WebViewController? _controller;
  HttpServer? _server;
  bool _isLoading = true;
  int? _serverPort;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      // 로컬 서버 시작
      _server = await HttpServer.bind('127.0.0.1', 0);
      _serverPort = _server!.port;

      print('서버 시작됨: http://127.0.0.1:$_serverPort');

      // 요청 핸들러
      _server!.listen((HttpRequest request) async {
        if (request.uri.path == '/') {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write(_getHtmlContent())
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      });

      // WebView 초기화
      _initWebView();
    } catch (e) {
      print('서버 시작 에러: $e');
    }
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('===== 주소 데이터 수신 =====');
          print(message.message);

          try {
            final data = jsonDecode(message.message);
            Navigator.pop(context, data);
          } catch (e) {
            print('JSON 파싱 에러: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('http://127.0.0.1:$_serverPort/'));

    setState(() {
      _controller = controller;
    });
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주소 검색</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; }
        #wrap { width: 100%; height: 100%; }
    </style>
</head>
<body>
    <div id="wrap"></div>
    
    <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script>
        window.addEventListener('load', function() {
            console.log('페이지 로드 완료');
            
            function initDaumPostcode() {
                if (typeof daum === 'undefined' || !daum.Postcode) {
                    setTimeout(initDaumPostcode, 100);
                    return;
                }
                
                console.log('Daum Postcode API 준비 완료');
                
                new daum.Postcode({
                    oncomplete: function(data) {
                        console.log('주소 선택됨:', JSON.stringify(data));
                        
                        if (window.AddressChannel) {
                            window.AddressChannel.postMessage(JSON.stringify(data));
                            console.log('Flutter로 전송 완료');
                        } else {
                            console.error('AddressChannel 없음');
                        }
                    },
                    width: '100%',
                    height: '100%'
                }).embed(document.getElementById('wrap'));
            }
            
            initDaumPostcode();
        });
    </script>
</body>
</html>
''';
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}