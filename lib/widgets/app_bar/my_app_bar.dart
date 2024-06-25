import 'package:flutter/material.dart';

/*MyAppBar (
            - title
            - Sorting options
            - refresh option
            - Fitering tabs
            - Search bar
*/

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(180);

  String title;
  var sortingChoices;
  void Function(String)? onSelected;
  late TabController Controller;
  var tabs;
  String searchLabel;
  final ValueChanged<String> onSearchTextChanged;

  MyAppBar(
      {required this.title,
      required this.sortingChoices,
      required this.onSelected,
      required this.Controller,
      required this.tabs,
      required this.searchLabel,
      required this.onSearchTextChanged,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppBar(
          title: Text('$title'),
          actions: [
            //Popup Menu (Refresh, Sortby)
            PopupMenuButton<String>(
                constraints:
                    const BoxConstraints.expand(width: 150, height: 115),
                surfaceTintColor: Colors.white,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Refresh',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Refresh'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Sort by',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Sort by'),
                        ),
                      ),
                    ],
                onSelected: onSelected)
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),

                    //Flitering tabs
                    child: TabBar(
                        dividerColor: Theme.of(context).primaryColor,
                        controller: Controller,
                        unselectedLabelColor: Colors.white,
                        labelColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: Colors.white,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        tabs: tabs),
                  ),

                  //Search Bar
                  Container(
                      color: Colors.white,
                      padding:
                          const EdgeInsets.only(top: 20, right: 20, left: 20),
                      child: TextField(
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          prefixIcon: const Icon(Icons.search),
                          hintText: searchLabel,
                          filled: true,
                          fillColor: Theme.of(context).secondaryHeaderColor,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ))
                ],
              )),
        ),
      ),
    );
  }
}
