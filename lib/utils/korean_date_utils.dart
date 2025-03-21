import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xml/xml.dart' as xml;

class KoreanDateUtils {
  /// 주어진 날짜의 전날을 반환합니다.
  /// 만약 전날이 주말이나 한국 공휴일인 경우, 파라미터 날짜로부터 가장 가까운 평일을 반환합니다.
  static Future<DateTime> getPreviousWorkday(DateTime date) async {
    // 하루 전 날짜 계산
    DateTime previousDay = date.subtract(const Duration(days: 1));

    // 주말 및 한국 공휴일 체크
    if (await isHoliday(previousDay)) {
      // 공휴일인 경우 재귀적으로 이전 평일 찾기
      return getPreviousWorkday(previousDay);
    }

    return previousDay;
  }

  static Future<bool> isHoliday(DateTime date) async {
    if (_isWeekend(date)) {
      return true;
    }

    return await _isKoreanHoliday(date);
  }

  static Future<bool> _isKoreanHoliday(DateTime date) async {
    try {
      // 공공데이터포털 API 키 (환경변수에서 가져오기)
      final serviceKey = dotenv.env['DATA_GO_KR_API_KEY'];
      if (serviceKey == null) {
        throw Exception('DATA_GO_KR_API_KEY 환경변수가 설정되지 않았습니다.');
      }

      // 날짜 포맷 (연도, 월)
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      // API 요청 URL 구성
      final url = Uri.parse('http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo'
          '?serviceKey=$serviceKey'
          '&solYear=$year'
          '&solMonth=$month');

      // API 요청
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // XML 응답 파싱
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        // 해당 날짜가 공휴일인지 확인
        for (var item in items) {
          final locdate = item.findElements('locdate').single.text;
          final isHoliday = item.findElements('isHoliday').single.text;

          // 날짜가 일치하고 공휴일이면 true 반환
          if (locdate == '$year$month$day' && isHoliday == 'Y') {
            return true;
          }
        }

        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static bool _isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7;
  }
}
