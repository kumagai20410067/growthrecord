import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:growthrecord/database_helper.dart' as DBHelper;
import 'package:growthrecord/home_page.dart';
import 'package:growthrecord/select_page.dart';

class GraphPage extends StatefulWidget {
  GraphPage({Key? key, required this.petId, required this.selectedPet})
      : super(key: key);

  final int petId;
  final String selectedPet;

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late DBHelper.DatabaseHelper _databaseHelper;
  int _selectedGraphIndex = 0;
  int _currentIndex = 2;
  DateTime _selectedMonth = DateTime.now();

  List<DateTime> dateList = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DBHelper.DatabaseHelper.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${widget.selectedPet}の成長グラフ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _buildGraphSelector(0, '全長'),
                        SizedBox(width: 24), //ボタンの間隔を調整
                        _buildGraphSelector(1, '体重'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        _selectPreviousMonth();
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text(
                      '${_selectedMonth.year}年${_selectedMonth.month}月',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        _selectNextMonth();
                      },
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildGraphArea(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'ペット選択',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'グラフ',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPage(),
              ),
            );
          } else if (index == 1) {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  petId: widget.petId,
                  selectedPet: widget.selectedPet,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildGraphSelector(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGraphIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedGraphIndex == index ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedGraphIndex == index ? Colors.white : Colors.black,
            fontSize: 18, //全長と体重選択ボタンの文字サイズ変更
          ),
        ),
      ),
    );
  }

  Widget _buildGraphArea() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _databaseHelper.retrieveMonthlyDataForGraph(
            widget.petId,
            '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('エラーが発生しました');
            } else if (snapshot.hasData) {
              final graphData = snapshot.data ?? [];
              // 空でない場合のみグラフを表示
              if (graphData.isNotEmpty) {
                dateList = _getDateList(graphData);

                return LineChart(
                  LineChartData(
                    // タッチ操作時の設定
                    lineTouchData: const LineTouchData(
                      handleBuiltInTouches: true, // タッチ時のアクションの有無
                      getTouchedSpotIndicator:
                          defaultTouchedIndicators, // インジケーターの設定
                      touchTooltipData: LineTouchTooltipData(
                        // ツールチップの設定
                        getTooltipItems: defaultLineTooltipItem, // 表示文字設定
                        tooltipBgColor: Colors.white, // 背景の色
                        tooltipRoundedRadius: 2.0, // 角丸
                      ),
                    ),

                    //背景グリッド線の設定
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1.0,
                      verticalInterval: 1.0,
                    ),

                    //グラフのタイトルの設定
                    titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          axisNameSize: 22.0,
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                bottomTitleWidgets(value, meta, dateList),
                            // interval: 1.0,
                            reservedSize: 30, //x軸の領域
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        )),

                    // グラフの外枠線
                    borderData: FlBorderData(
                      show: true, // 外枠線の有無
                      border: Border.all(
                        color: Color(0xff37434d), // 外枠線の色
                      ),
                    ),

                    // グラフのx軸y軸のの表示数
                    minX: 1.0,
                    maxX: graphData.length.toDouble(),
                    minY: graphData.isEmpty
                        ? 0
                        : graphData
                                .map((data) => _selectedGraphIndex == 0
                                    ? data['height']
                                    : data['weight'])
                                .reduce((a, b) => a < b ? a : b) -
                            1,
                    maxY: graphData.isEmpty
                        ? 100
                        : graphData
                                .map((data) => _selectedGraphIndex == 0
                                    ? data['height']
                                    : data['weight'])
                                .reduce((a, b) => a > b ? a : b) +
                            1,
                    lineBarsData: [
                      if (_selectedGraphIndex == 0)
                        LineChartBarData(
                          spots: graphData
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble() + 1,
                                  entry.value['height'].toDouble(),
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          barWidth: 1.0,
                          isStrokeCapRound: false,
                          dotData: FlDotData(
                            show: true, // 座標のドット表示の有無
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              // ドットの詳細設定
                              radius: 2.0,
                              color: Colors.blue,
                              strokeWidth: 2.0,
                              strokeColor: Colors.blue,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                      if (_selectedGraphIndex == 1)
                        LineChartBarData(
                          spots: graphData
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble() + 1,
                                  entry.value['weight'].toDouble(),
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          barWidth: 1.0,
                          isStrokeCapRound: false,
                          dotData: FlDotData(
                            show: true, // 座標のドット表示の有無
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              // ドットの詳細設定
                              radius: 2.0,
                              color: Colors.blue,
                              strokeWidth: 2.0,
                              strokeColor: Colors.blue,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            // チャート線下部に色を付ける場合の設定
                            show: false, // チャート線下部の表示の有無
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                return const Text('データがありません');
              }
            } else {
              return const Text('データの取得中...');
            }
          },
        ),
      ),
    );
  }

  void _selectPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _selectNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }
}

List<DateTime> _getDateList(List<Map<String, dynamic>> graphData) {
  return graphData
      .map((data) => DateTime.parse(data['date']).toLocal())
      .map((date) => DateTime(date.year, date.month, date.day)) // 日付のフォーマットを修正
      .toList();
}

Widget bottomTitleWidgets(
    double value, TitleMeta meta, List<DateTime> dateList) {
  const style = TextStyle(
    color: Color(0xff68737d),
    fontWeight: FontWeight.bold,
    fontSize: 12.0,
  );

  final index = value.toInt() - 1;

  Widget text;
  if (index >= 0 && index < dateList.length) {
    final day = dateList[index].day;
    final month = dateList[index].month;
    text = Text('$month/$day', style: style);
  } else {
    text = const Text('', style: style);
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}
