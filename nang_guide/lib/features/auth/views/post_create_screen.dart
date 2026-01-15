import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  // 지도 설정을 위한 변수 추가
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.3402, 126.7335);
  final Set<Marker> _markers = {}; // 마커 표시
  // 사용자가 직접 입력할 수 있도록 컨트롤러 연결
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedType = '공동구매';
  String _location = '장소를 선택해주세요';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // 지도 클릭 시 마커 생성
  void _onTapMap(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
        ),
      );
      _currentPosition = position;
    });
  }
 
  // 장소 클릭 시 뜨는 지도 팝업
  void _showMapDialog() {
    // 팝업이 열릴 때, 현재 위치에 마커가 찍혀있게 미리 설정
    setState(() {
      _onTapMap(_currentPosition);
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Center(child: Text("만날 장소를 선택해주세요", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("(해당 위치는 만날 장소 기준입니다)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),
              Container(
                height: 300,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onTap: (LatLng pos) {
                    // 다이얼로그 내 마커 업데이트를 위해 setDialogState 사용
                    setDialogState(() {
                      _markers.clear();
                      _markers.add(Marker(markerId: const MarkerId('1'), position: pos));
                      _currentPosition = pos;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  setState(() => _location = "${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}"); // 임시 데이터
                  Navigator.pop(context);
                },
                child: const Text("위치 설정 완료", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게시물 작성하기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("게시물 종류", style: TextStyle(fontSize: 12, color: Colors.grey)),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['공동구매',"식사",'나눔','정보공유'].map(
                      (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e)
                      )
              ).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("게시물 제목", style: TextStyle(fontSize: 12, color: Colors.grey)),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "제목을 입력하세요", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            // --- 조건부 렌더링: 공동구매 / 나눔일 때만 기간 입력창 노출
            // 1) 공동구매
            if(_selectedType == '공동구매') ...[
              _buildLabel("공동구매 기간"),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  hintText: "예: 26.01.12 ~ 26.02.07",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
           
            // 2) 나눔
            if(_selectedType == '나눔') ...[
              _buildLabel("나눔 기간"),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  hintText: "예: 26.01.12 ~ 26.02.07",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text("게시물 설명", style: TextStyle(fontSize: 12, color: Colors.grey)),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: "내용을 입력하세요", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("만날 장소", style: TextStyle(fontSize: 12, color: Colors.grey)),
            InkWell(
              onTap: _showMapDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_location, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("작성하기", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // 레이블 스타일 공통 위젯
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}