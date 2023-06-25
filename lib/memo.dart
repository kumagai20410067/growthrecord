import 'package:flutter/material.dart';
import 'package:growthrecord/home_page.dart';
import 'package:growthrecord/select_page.dart';
class MemoPage extends StatefulWidget {
final String selectedPet;

const MemoPage({Key? key, required this.selectedPet}) : super(key: key);
@override
  State<MemoPage> createState() => _MemoPageState();
}
class _MemoPageState extends State<MemoPage>{
     int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context){

    return Scaffold(
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
                MaterialPageRoute(builder: (context) => MemoPage(selectedPet: widget.selectedPet,)),
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






