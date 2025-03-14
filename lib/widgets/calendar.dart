import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/constants/salad_state.dart';
import 'package:koscom_salad/services/models/salad_model.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';

class Calendar extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final VoidCallback onAppointmentCreated;
  final Future<List<SaladModel>> saladsFuture;

  const Calendar({
    super.key,
    required this.saladsFuture,
    required this.onDateChanged,
    required this.onAppointmentCreated,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // 현재 달을 기준으로 앞뒤로 2년씩 표시할 수 있도록 설정
  static const int totalMonths = 48;
  static const int initialPage = totalMonths ~/ 2; // 중간 페이지에서 시작

  late DateTime _calendarPageDay;
  late PageController _calendarPageController;

  @override
  void initState() {
    super.initState();
    _calendarPageController = PageController(initialPage: initialPage);
    _calendarPageDay = getDateFromIndex(initialPage);

    // build 완료 후 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged(_calendarPageDay);
    });
  }

  DateTime getDateFromIndex(int index) {
    // initialPage를 기준으로 상대적인 월 계산
    final monthDiff = index - initialPage;
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + monthDiff,
      1,
    );
  }

  _onCalendarSwiped(int index) {
    setState(() {
      _calendarPageDay = getDateFromIndex(index);
      widget.onDateChanged(_calendarPageDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 540, // 캘린더의 전체 높이
      child: PageView.builder(
        controller: _calendarPageController,
        onPageChanged: _onCalendarSwiped,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('일', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('월', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('화', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('수', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('목', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('금', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('토', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<SaladModel>>(
                  future: widget.saladsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _makeCalendar(snapshot.data!);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  GridView _makeCalendar(List<SaladModel> salads) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95, // 캘린더 셀 간격 (셀 크기 비율)
        mainAxisSpacing: 12, // 세로 방향 간격
        // crossAxisSpacing: 8, // 가로 방향 간격
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final firstDay = DateTime(_calendarPageDay.year, _calendarPageDay.month, 1);
        final lastDay = DateTime(_calendarPageDay.year, _calendarPageDay.month + 1, 0);
        final firstWeekday = firstDay.weekday;
        final day = index - (firstWeekday - 1);
        final date = DateTime(_calendarPageDay.year, _calendarPageDay.month, day);

        // 1일 이전이거나 이번 달의 마지막 날 이후면 빈 공간을 반환
        if (day < 1 || date.isAfter(lastDay)) {
          return const SizedBox.shrink();
        }

        final SaladModel? salad = salads
            .where((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day)
            .firstOrNull;

        return _makeCell(date, salad);
      },
    );
  }

  Widget _makeCell(DateTime date, SaladModel? salad) {
    final isPastDate = date.isBefore(DateTime.now());
    const size = 36.0;

    // 과거 날짜이고 예약된 샐러드가 없는 경우
    if (isPastDate && salad == null) {
      final icon = _buildSaladImage(
        size: size,
        filterColor: const Color(0xfff4f4f4),
        blendMode: BlendMode.srcIn,
      );
      return _buildCell(icon, date);
    }

    // 미래 날짜이고 예약된 샐러드가 없는 경우
    if (!isPastDate && salad == null) {
      final icon = _buildSaladImage(
        size: size,
        opacity: 0.3,
      );
      return _buildCell(
        icon,
        date,
        onTap: () => DialogUtils.showAppointmentCreateDialog(
          date,
          onComplete: widget.onAppointmentCreated,
        ),
      );
    }

    // 예약된 샐러드가 있는 경우
    final icon = _buildSaladImage(
      size: size,
      filterColor: salad?.state == SaladState.spoiled ? const Color.fromARGB(255, 162, 1, 206) : null,
      blendMode: salad?.state == SaladState.spoiled ? BlendMode.modulate : null,
    );

    return _buildCell(
      icon,
      date,
      onTap: !isPastDate
          ? () => DialogUtils.showAppointmentEditDialog(
                date,
                salad!.appointmentId,
                onComplete: widget.onAppointmentCreated,
              )
          : null,
    );
  }

  // 날짜 텍스트 위젯 생성
  Widget _buildDateText(DateTime date, double fontSize) {
    return Text(
      date.day.toString(),
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }

  // 샐러드 아이콘 위젯 생성
  Widget _buildSaladImage({
    required double size,
    double opacity = 1.0,
    Color? filterColor,
    BlendMode? blendMode,
  }) {
    Widget icon = Image.asset(ImagePaths.salad);

    if (filterColor != null && blendMode != null) {
      icon = ColorFiltered(
        colorFilter: ColorFilter.mode(filterColor, blendMode),
        child: icon,
      );
    }

    if (opacity != 1.0) {
      icon = Opacity(opacity: opacity, child: icon);
    }

    return SizedBox(
      width: size,
      height: size,
      child: icon,
    );
  }

  // 날짜 셀 컨테이너 생성
  Widget _buildCell(Widget icon, DateTime date, {VoidCallback? onTap}) {
    Widget content = Column(
      children: [
        icon,
        _buildDateText(date, 12),
      ],
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
