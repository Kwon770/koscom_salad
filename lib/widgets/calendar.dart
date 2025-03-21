import 'package:flutter/material.dart';
import 'package:koscom_salad/constants/image_paths.dart';
import 'package:koscom_salad/constants/salad_state.dart';
import 'package:koscom_salad/services/appointment_service.dart';
import 'package:koscom_salad/services/models/salad_model.dart';
import 'package:koscom_salad/services/salad_service.dart';
import 'package:koscom_salad/utils/dialog_utils.dart';
import 'package:koscom_salad/utils/korean_date_utils.dart';

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

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  // 현재 달을 기준으로 앞뒤로 2년씩 표시할 수 있도록 설정
  static const int totalMonths = 48;
  static const int initialPage = totalMonths ~/ 2; // 중간 페이지에서 시작

  late DateTime _calendarPageDay;
  late PageController _calendarPageController;
  final Map<DateTime, AnimationController> _animationControllers = {};

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

  @override
  void dispose() {
    // 모든 애니메이션 컨트롤러 해제
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _animationControllers.clear();
    super.dispose();
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
        childAspectRatio: 1, // 캘린더 셀 간격 (셀 크기 비율)
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

        // FutureBuilder를 사용하여 Future<Widget>을 Widget으로 변환
        return FutureBuilder<Widget>(
          future: _makeCell(date, salad),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return snapshot.data!;
            }
            return const SizedBox.shrink(); // 로딩 중일 때 표시할 위젯
          },
        );
      },
    );
  }

  Future<Widget> _makeCell(DateTime date, SaladModel? salad) async {
    final isHoliday = await KoreanDateUtils.isHoliday(date);
    const iconSize = 36.0;

    // 예약된 샐러드가 없는경우
    if (salad == null) {
      final isPastThanDate = date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1));
      if (isHoliday || isPastThanDate) {
        return _buildGrayCell(iconSize, date);
      } else {
        return _buildTransparentSaladCell(iconSize, date);
      }
    }

    // 예약된 샐러드가 있는 경우
    return _buildSolidSaladCell(iconSize, salad, date);
  }

  Future<Widget> _buildSolidSaladCell(double iconSize, SaladModel salad, DateTime date) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPastEqualThanToday = date.isBefore(today) || KoreanDateUtils.isSameDay(date, today);

    // 현재 시간 가져오기
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;

    // 애니메이션이 필요한 조건 확인
    bool needsAnimation = false;
    VoidCallback? onTapAction;

    if (salad.state == SaladState.spoiled || salad.state == SaladState.takeHome) {
      // spoiled, takeHome 상태인 경우, 더 이상 액션 없음
    }
    // 1. "샐러드를 신청하셨나요?" 조건
    else if (KoreanDateUtils.isSameDay(await KoreanDateUtils.getPreviousWorkday(date), today) &&
        salad.state == SaladState.booked &&
        currentTimeInMinutes > (16 * 60 + 49)) {
      needsAnimation = true;
      onTapAction = () async {
        // 샐러드 신청 관련 액션
        bool? applyResult = await DialogUtils.showYesOrNoDialog(
          ImagePaths.salad,
          title: "샐러드 신청하셨나요?",
          message: "",
          yesText: "신청 성공했다",
          noText: "신청 실패했다",
        );

        if (applyResult == true) {
          await SaladService.applySalad(salad.id);
          widget.onAppointmentCreated();
        } else if (applyResult == false) {
          await SaladService.deleteSalad(salad.id);
          await AppointmentService.deleteAppointment(salad.appointmentId);
          widget.onAppointmentCreated();
        }
      };
    }
    // 2. "샐러드를 픽업하셨나요?" 조건
    else if (KoreanDateUtils.isSameDay(date, today) &&
        (salad.state == SaladState.booked || salad.state == SaladState.applied) &&
        currentTimeInMinutes > (12 * 60 + 20)) {
      needsAnimation = true;
      onTapAction = () async {
        // 샐러드 픽업 관련 액션
        bool? pickedupResult = await DialogUtils.showYesOrNoDialog(
          ImagePaths.salad,
          title: "샐러드 픽업하셨나요?",
          message: "",
          yesText: "픽업 및 양도했다",
          noText: "깜빡해서 폐기됬다",
        );

        if (pickedupResult == true) {
          await SaladService.pickUpSalad(salad.id);
          widget.onAppointmentCreated();
        } else if (pickedupResult == false) {
          await SaladService.spoilSalad(salad.id);
          widget.onAppointmentCreated();
        }
      };
    }
    // 3. "샐러드를 챙기셨나요?" 조건
    else if ((KoreanDateUtils.isSameDay(date, today) &&
            (salad.state == SaladState.applied || salad.state == SaladState.pickedUp) &&
            currentTimeInMinutes > (17 * 60 + 40)) ||
        (date.isBefore(today) && (salad.state == SaladState.booked || salad.state == SaladState.pickedUp))) {
      needsAnimation = true;
      onTapAction = () async {
        // 샐러드 챙기기 관련 액션
        bool? takehomeResult = await DialogUtils.showYesOrNoDialog(
          ImagePaths.salad,
          title: "샐러드 챙기셨나요?",
          message: "",
          yesText: "챙겼다",
          noText: "회사에 두고왔다...",
        );

        if (takehomeResult == true) {
          await SaladService.takeHomeSalad(salad.id);
          widget.onAppointmentCreated();
        } else if (takehomeResult == false) {
          await SaladService.spoilSalad(salad.id);
          widget.onAppointmentCreated();
        }
      };
    }
    // 일반적인 경우
    else if (!isPastEqualThanToday) {
      onTapAction = () => DialogUtils.showAppointmentEditDialog(
            date,
            salad.appointmentId,
            onComplete: widget.onAppointmentCreated,
          );
    }

    // 애니메이션 컨트롤러 생성 또는 가져오기
    if (needsAnimation && !_animationControllers.containsKey(date)) {
      _animationControllers[date] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..repeat(reverse: true);
    } else if (!needsAnimation && _animationControllers.containsKey(date)) {
      _animationControllers[date]!.dispose();
      _animationControllers.remove(date);
    }

    // 아이콘 생성
    final icon = _buildSaladImage(
      size: iconSize,
      filterColor: salad.state == SaladState.spoiled ? const Color.fromARGB(255, 162, 1, 206) : null,
      blendMode: salad.state == SaladState.spoiled ? BlendMode.modulate : null,
    );

    // 애니메이션 적용 - 더 크고 빠르게
    Widget finalIcon = icon;
    if (needsAnimation && _animationControllers.containsKey(date)) {
      // 애니메이션 속도 조정
      _animationControllers[date]!.duration = const Duration(milliseconds: 500);

      finalIcon = AnimatedBuilder(
        animation: _animationControllers[date]!,
        builder: (context, child) {
          return Transform.scale(
            // 스케일 범위를 0.8에서 1.4로 확장 (더 크게)
            scale: 1.0 + 0.3 * _animationControllers[date]!.value,
            child: child,
          );
        },
        child: icon,
      );
    }

    return _buildCell(
      finalIcon,
      date,
      onTap: onTapAction,
    );
  }

  Widget _buildTransparentSaladCell(double size, DateTime date) {
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

  Widget _buildGrayCell(double size, DateTime date) {
    final icon = _buildSaladImage(
      size: size,
      filterColor: const Color(0xfff4f4f4),
      blendMode: BlendMode.srcIn,
    );

    return _buildCell(icon, date);
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
