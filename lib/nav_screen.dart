import 'package:flutter/material.dart';
import 'package:le_kpao/screens/quiz_screen.dart';
import 'package:le_kpao/screens/claim_screen.dart';
import 'package:le_kpao/screens/topics_screen.dart';
import 'package:le_kpao/screens/payment_screen.dart';
import 'package:le_kpao/screens/products_screen.dart';
import 'package:le_kpao/screens/dashboard_screen.dart';
import 'package:le_kpao/screens/competition_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({
    super.key,
    required this.uid
  });

  final String uid;

  @override
  State<NavScreen> createState() => NavScreenState();
}

class NavScreenState extends State<NavScreen> with TickerProviderStateMixin{
  int index = 0;
  String number = " ";
  bool displayDrawer = true;

  @override
  void initState(){
    super.initState();

    if(widget.uid != 'archetechnology1011@gmail.com'){
      index = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    String device = "desktop";
    double width = MediaQuery.of(context).size.width;
    if(width < 768){
      device = "mobile";
    }

    Widget myDrawer = SizedBox(
        width: 280,
        child: Drawer(
            elevation: 0,
            backgroundColor: const Color(0xff222d32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0)
            ),
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  device == "mobile" ? Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                              Icons.close
                          )
                      )
                  ) : const SizedBox(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        widget.uid == 'archetechnology1011@gmail.com' ?
                        Row(
                            children: [
                              index == 0 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 0;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.speed_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("DASHBOARD")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ) :
                        const SizedBox(),

                        Row(
                            children: [
                              index == 1 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 1;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.book_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("SUJETS")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),

                        Row(
                            children: [
                              index == 2 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 2;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.assignment_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("ANNALES")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),

                        Row(
                            children: [
                              index == 3 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 3;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.assignment_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("CONCOURS")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),

                        Row(
                            children: [
                              index == 4 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 4;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.quiz_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("QUIZ")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),

                        Row(
                            children: [
                              index == 6 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 6;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.monetization_on_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("PAIEMENTS")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),

                        widget.uid == 'archetechnology1011@gmail.com' ?
                        Row(
                            children: [
                              index == 5 ?
                              Container(
                                  height: 45,
                                  width: 4,
                                  decoration: const BoxDecoration(
                                      color: Colors.orange
                                  )
                              ):
                              const SizedBox(),
                              Expanded(
                                  child: SizedBox(
                                      height: 45,
                                      child: TextButton(
                                          onPressed: (){
                                            setState(() {
                                              index = 5;
                                            });
                                          },
                                          child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.contact_support_rounded,
                                                    color: Color(0xffb8c7ce)
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text("RECLAMATIONS")
                                                ),
                                                Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    size: 15,
                                                    color: Color(0xffb8c7ce)
                                                )
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ) :
                        const SizedBox(),
                        SizedBox(
                            height: 45,
                            child: TextButton(
                                onPressed: (){

                                },
                                child: const Row(
                                    children: [
                                      Icon(
                                          Icons.power_off_rounded,
                                          color: Color(0xffb8c7ce)
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                          child: Text("DECONNEXION")
                                      ),
                                      Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                          color: Color(0xffb8c7ce)
                                      )
                                    ]
                                )
                            )
                        )
                      ]
                  )
                ]
            )
        )
    );

    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            title: Row(
                children: [
                  const SizedBox(
                    width: 10
                  ),
                  const SizedBox(
                      width: 238,
                      child: Text(
                          "ADMIN LE KPAO",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          )
                      )
                  ),
                  TextButton(
                      onPressed: (){
                        setState(() {
                          if(displayDrawer){
                            displayDrawer = false;
                          }
                          else{
                            displayDrawer = true;
                          }
                        });
                      },
                      child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white
                      )
                  )
                ]
            ),
            backgroundColor: const Color(0xfff39c12)
        ),
        drawer: device == "mobile" ? myDrawer : null,
        body: SafeArea(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (device == "desktop" &&  displayDrawer) ? myDrawer : const SizedBox(),
                  Expanded(
                      flex: 2,
                      child: index == 0 ?
                      const DashboardScreen() :
                      index == 1 ?
                      const TopicsScreen(uid: "archetechnology1011@gmail.com") :
                      index == 2 ?
                      const ProductsScreen(uid: "archetechnology1011@gmail.com"):
                      index == 3 ?
                      const CompetitionScreen() :
                      index == 4 ?
                      const QuizScreen():
                      index == 5 ?
                      const ClaimScreen():
                      index == 6 ?
                      const PaymentScreen():
                      const SizedBox()
                  )
                ]
            )
        )
    );
  }
}
