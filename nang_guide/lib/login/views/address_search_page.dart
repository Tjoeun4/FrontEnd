import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ----------------------------------------------------
/// 주소 검색 전용 페이지
/// - Flutter WebView 내부에서 Daum Postcode UI 실행
/// - 로컬 HTTP 서버를 통해 HTML을 제공
/// - JavaScriptChannel로 주소 데이터를 Flutter로 전달
/// ----------------------------------------------------
class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({Key? key}) : super(key: key);

  @override
  _AddressSearchPageState createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  /// WebView 제어용 컨트롤러
  WebViewController? _controller;

  /// HTML 제공을 위한 로컬 HTTP 서버
  HttpServer? _server;

  /// WebView 로딩 상태 표시용 플래그
  bool _isLoading = true;

  /// 동적으로 할당된 로컬 서버 포트
  int? _serverPort;

  /// ----------------------------------------------------
  /// 페이지 초기화
  /// - 로컬 서버 실행 → WebView 초기화
  /// ----------------------------------------------------
  @override
  void initState() {
    super.initState();
    _startServer();
  }

  /// ====================================================
  /// 로컬 HTTP 서버 시작
  ///
  /// 목적:
  /// - WebView에서 로컬 HTML을 file:// 이 아닌
  ///   http:// 로 제공하기 위함
  /// ====================================================
  Future<void> _startServer() async {
    try {
      // 로컬 서버 시작
      // 사용 가능한 임의 포트로 서버 바인딩
      _server = await HttpServer.bind('127.0.0.1', 0);
      _serverPort = _server!.port;

      print('서버 시작됨: http://127.0.0.1:$_serverPort');

      // 요청 핸들러
      // 단일 엔드포인트로 HTML 제공
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

      // 서버 준비 완료 후 WebView 초기화
      _initWebView();
    } catch (e) {
      print('서버 시작 에러: $e');
    }
  }

  /// ====================================================
  /// WebView 초기 설정
  /// - JavaScript 활성화
  /// - AddressChannel 등록
  /// - 로컬 서버 주소 로드
  /// ====================================================
  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      /// ----------------------------------------------
      /// JavaScript → Flutter 통신 채널
      /// - HTML에서 postMessage로 주소 데이터 전달
      /// ----------------------------------------------
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('===== 주소 데이터 수신 =====');
          print(message.message);

          try {
            final data = jsonDecode(message.message);
            // 주소 선택 완료 → 이전 화면으로 결과 반환
            Navigator.pop(context, data);
          } catch (e) {
            print('JSON 파싱 에러: $e');
          }
        },
      )
      /// ----------------------------------------------
      /// WebView 로딩 상태 관리
      /// ----------------------------------------------
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
      // 로컬 서버에서 HTML 로드
      ..loadRequest(Uri.parse('http://127.0.0.1:$_serverPort/'));

    setState(() {
      _controller = controller;
    });
  }

  /// ====================================================
  /// Daum Postcode UI를 포함한 HTML 문자열
  /// - WebView에서 렌더링됨
  /// - 주소 선택 시 AddressChannel로 결과 전송
  /// ====================================================
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

  /// ----------------------------------------------------
  /// 리소스 정리
  /// - 로컬 서버 종료
  /// ----------------------------------------------------
  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  /// ----------------------------------------------------
  /// 화면 구성
  /// - WebView + 로딩 인디케이터
  /// ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
