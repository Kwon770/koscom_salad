import 'package:flutter/material.dart';

class UpcomingSaladList extends StatefulWidget {
  const UpcomingSaladList({super.key});

  @override
  State<UpcomingSaladList> createState() => _UpcomingSaladListState();
}

class _UpcomingSaladListState extends State<UpcomingSaladList> {
  // TODO: API 호출을 통해 실제 데이터로 교체 필요
  final List<Map<String, dynamic>> _upcomingSalads = [
    {
      'date': '2024-01-15',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-16',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-17',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-15',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-16',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-17',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-15',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-16',
      'name': '점심 약속',
    },
    {
      'date': '2024-01-17',
      'name': '점심 약속',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '예정된 샐러드',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _upcomingSalads.length,
          itemBuilder: (context, index) {
            final salad = _upcomingSalads[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  salad['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '예약일: ${salad['date']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
