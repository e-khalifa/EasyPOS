import 'package:flutter/material.dart';

/*SalesAppBar (
            - Title         
            - Order Label
            - Custom widget)

  Used in: 
            - SalesOpsPage
            - AdiingProductPage         
*/

class SalesAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(180);

  String title;
  String? orderLabel;
  Widget? customWidget;

  SalesAppBar(
      {required this.title,
      required this.orderLabel,
      required this.customWidget,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppBar(
          //Title
          title: Text(title),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Column(
                children: [
                  //Order Label
                  Container(
                      width: double.infinity,
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      color: const Color.fromARGB(255, 255, 244, 210),
                      child: Text(
                        '$orderLabel',
                      )),

                  //Custom Widget
                  Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: customWidget)
                ],
              )),
        ),
      ),
    );
  }
}
