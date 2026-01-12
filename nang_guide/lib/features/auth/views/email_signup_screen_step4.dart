import 'package:flutter/material.dart';
import 'address_search_page.dart';

class EmailSignUpScreenStep4 extends StatefulWidget {
  const EmailSignUpScreenStep4({Key? key}) : super(key: key);

  @override
  State<EmailSignUpScreenStep4> createState() => _EmailSignUpScreenStep4State();
}

class _EmailSignUpScreenStep4State extends State<EmailSignUpScreenStep4> {
  String _zonecode = '';
  String _roadAddress = '';
  final TextEditingController _detailAddressController = TextEditingController();

  @override
  void dispose() {
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 가입 (4/4)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressSearchPage()),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _zonecode = result['zonecode'] ?? '';
                    _roadAddress = result['roadAddress'] ?? result['jibunAddress'] ?? '';
                  });
                  print('받은 주소 데이터: $result');
                }
              },
              child: const Text('주소 검색'),
            ),
            const SizedBox(height: 24),

            // 선택된 주소 표시 영역
            Text(
              '선택된 주소:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 우편번호
            Row(
              children: [
                Text(
                  '우편번호: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _zonecode.isEmpty ? '주소를 검색해주세요' : _zonecode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _zonecode.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 기본 주소
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본 주소: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    _roadAddress.isEmpty ? '주소를 검색해주세요' : _roadAddress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _roadAddress.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 상세 주소 입력 필드
            TextField(
              controller: _detailAddressController,
              decoration: InputDecoration(
                labelText: '상세 주소',
                hintText: '동/호수 등 상세 주소를 입력해주세요',
                border: OutlineInputBorder(),
                enabled: _roadAddress.isNotEmpty,
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // 전체 주소 미리보기 (선택사항)
            if (_roadAddress.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 주소',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '($_zonecode) $_roadAddress${_detailAddressController.text.isNotEmpty ? ', ${_detailAddressController.text}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 16),

            // 하단 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('이전'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _roadAddress.isEmpty
                        ? null
                        : () {
                      // 최종 주소 데이터
                      final fullAddress = {
                        'zonecode': _zonecode,
                        'roadAddress': _roadAddress,
                        'detailAddress': _detailAddressController.text,
                        'fullAddress': '($_zonecode) $_roadAddress${_detailAddressController.text.isNotEmpty ? ', ${_detailAddressController.text}' : ''}',
                      };

                      print('최종 주소 데이터: $fullAddress');

                      // TODO: 회원가입 완료 로직
                      // 여기서 fullAddress 데이터를 서버로 전송
                    },
                    child: const Text('회원가입 완료'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}