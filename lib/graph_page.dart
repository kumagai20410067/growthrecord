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

class _GraphPageState extends State<GraphPage>{
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,//デフォルトの戻るボタンを削除
        title: const Text(''),
        ),
body: Padding(
  padding:const EdgeInsets.all(16),
  child: LineChart(
          LineChartData(
            lineBarsData: [
            LineChartBarData(spots: const [
              FlSpot(1, 323),
              FlSpot(2, 538),
              FlSpot(3, 368),
              FlSpot(4, 259),
              FlSpot(5, 551),
              FlSpot(6, 226),
              FlSpot(7, 268),
              FlSpot(8, 296),
              FlSpot(9, 203),
              FlSpot(10, 246),
              FlSpot(11, 345),
            ])
          ],
          titlesData: const FlTitlesData(
            leftTitles:AxisTitles(sideTitles: SideTitles(showTitles: false)),//左のタイトルを非表示
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),//上のタイトルを非表示
             )
          ),
        ),
   ),
//フッター
bottomNavigationBar: BottomNavigationBar(
          items:const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.date_range),
              label: 'CaLendar'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Graph'
              ),
          ],
          onTap: (int index){
            setState(() {
              _currentIndex = index;
            });

            switch(index){
              case 0:
                Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SelectPage()),
             );
               break;
               case 1:
                Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) =>  MyHomePage(selectedPet: widget.selectedPet)),
             );
               break;
              case 2:
                Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => GraphPage(selectedPet: widget.selectedPet,)),
             );
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