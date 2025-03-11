import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';

class Calendar extends StatefulWidget {
  final Function(DateTime) onDateChanged;

  const Calendar({
    super.key,
    required this.onDateChanged,
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

  onCalendarSwiped(int index) {
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
        onPageChanged: onCalendarSwiped,
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.89,
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

                    return GestureDetector(
                      onTap: () => DialogUtils.showAppointmentEditDialog(date),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(4),
                            width: 36.5,
                            height: 36.5,
                            child: Image.asset(ImagePaths.saladMask),
                          ),
                          Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
