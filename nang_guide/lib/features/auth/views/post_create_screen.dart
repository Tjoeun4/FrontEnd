import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.3402, 126.7335);
  final Set<Marker> _markers = {};

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedType = '공동구매';
  String _location = '장소를 선택해주세요';

  // 기간 선택용 상태 변수
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // --- 핵심: 한 달씩 넘기는 팝업 달력 함수 ---
  void _showCustomDateRangePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("기간 설정", style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)
                    ),

                    const SizedBox(height: 10),
                    // 화살표로 한 달씩 넘기는 달력 위젯
                    SizedBox(
                      height: 330,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF6750A4)),
                        ),
                        child: CalendarDatePicker(
                          initialDate: _tempStartDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          onDateChanged: (DateTime date) {
                            setDialogState(() {
                              if (_tempStartDate == null || (_tempStartDate != null && _tempEndDate != null)) {
                                _tempStartDate = date;
                                _tempEndDate = null;
                              } else if (date.isBefore(_tempStartDate!)) {
                                _tempStartDate = date;
                              } else {
                                _tempEndDate = date;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    // 선택된 기간 표시 영역 (달력 밑)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            _tempStartDate == null
                                ? "시작 날짜를 선택하세요"
                                : "${_tempStartDate!.year}.${_tempStartDate!.month}.${_tempStartDate!.day} ~ "
                                "${_tempEndDate == null
                                ? '종료 날짜 선택'
                                : '${_tempEndDate!.year}.${_tempEndDate!.month}.${_tempEndDate!.day}'}",
                            style: TextStyle(
                                fontSize: 14,
                                color: _tempEndDate == null ? Colors.grey : Colors.black,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("취소", style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6750A4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _tempEndDate == null ? null : () {
                                    setState(() {
                                      String start = "${_tempStartDate!.year.toString().substring(2)}.${_tempStartDate!.month.toString().padLeft(2, '0')}.${_tempStartDate!.day.toString().padLeft(2, '0')}";
                                      String end = "${_tempEndDate!.year.toString().substring(2)}.${_tempEndDate!.month.toString().padLeft(2, '0')}.${_tempEndDate!.day.toString().padLeft(2, '0')}";
                                      _dateController.text = "$start ~ $end";
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("확인", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 기존 지도 다이얼로그 및 라벨 유지 ---
  void _onMapCreated(GoogleMapController controller) => _mapController = controller;
  void _onTapMap(LatLng pos) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(markerId: const MarkerId('selected'), position: pos));
      _currentPosition = pos;
    });
  }

  void _showMapDialog() {
    setState(() => _onTapMap(_currentPosition));
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Center(
                child: Text("만날 장소를 선택해주세요",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)
                )
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("(해당 위치는 만날 장소 기준입니다)",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey
                    )
                ),

                const SizedBox(height: 15),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                    markers: _markers,
                    onTap: (LatLng pos) {
                      setDialogState(() => _onTapMap(pos));
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
                    setState(() => _location = "${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}");
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
        title: const Text("게시물 작성하기",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
        ),

        backgroundColor: Colors.white, elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("게시물 종류"),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['공동구매',"식사",'나눔','정보공유']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _buildLabel("게시물 제목"),
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    hintText: "제목을 입력하세요",
                    border: OutlineInputBorder()
                )
            ),

            const SizedBox(height: 20),

            // --- 수정된 부분: 입력창 대신 버튼처럼 동작하게 구현 ---
            if(_selectedType == '공동구매' || _selectedType == '나눔') ...[
              _buildLabel("$_selectedType 기간"),
              InkWell(
                onTap: _showCustomDateRangePicker, // 탭하면 무조건 팝업 실행
                child: IgnorePointer( // 내부 TextField의 터치 이벤트를 무시하여 부모 InkWell이 받게 함
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      hintText: "날짜 범위를 선택하세요",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            _buildLabel("게시물 설명"),
            TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText: "내용을 입력하세요",
                    border: OutlineInputBorder()
                )
            ),

            const SizedBox(height: 20),
            _buildLabel("만날 장소"),
            InkWell(
              onTap: _showMapDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4)
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_location,
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold
                        )
                    ),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  )
              ),

              child: const Text("작성하기", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 5),
        child: Text(text, style:
          const TextStyle(
            fontSize: 12,
            color: Colors.grey
          )
        )
    );
  }
}