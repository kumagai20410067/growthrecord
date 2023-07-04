import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:growthrecord/home_page.dart';
import 'package:growthrecord/select_page.dart';

class GraphPage extends StatefulWidget {
  final String selectedPet;

  const GraphPage({Key? key, required this.selectedPet}) : super(key: key);

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //デフォルトの戻るボタンを削除
        title: Text('${widget.selectedPet}の成長記録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
              lineBarsData: [
                LineChartBarData(spots: const [
                  FlSpot(1, 523),
                  FlSpot(2, 524),
                  FlSpot(3, 525),
                  FlSpot(4, 526),
                  FlSpot(5, 527),
                  FlSpot(6, 528),
                  FlSpot(7, 529),
                ])
              ],
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)), //左のタイトルを非表示
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)), //上のタイトルを非表示
              )),
        ),
      ),
//フッター
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.date_range), label: 'CaLendar'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Graph'),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SelectPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MyHomePage(selectedPet: widget.selectedPet)),
              );
              break;
            case 2:
              // 現在のページ
              break;
          }
        },
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
      ),
    );
  }
}
