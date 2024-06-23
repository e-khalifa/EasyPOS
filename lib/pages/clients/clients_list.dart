import 'package:easy_pos_project/widgets/app_widgets/my_app_bar.dart';
import 'package:easy_pos_project/widgets/clients_info.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:route_transitions/route_transitions.dart';

import '../../helpers/sql_helper.dart';
import '../../models/client.dart';
import '../../widgets/app_widgets/my_card.dart';
import '../../widgets/app_widgets/my_item_deleted_dialog.dart';
import 'clients_ops.dart';

enum StatusFilter { all, localClients }

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  _ClientsListPageState createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var sqlHelper = GetIt.I.get<SqlHelper>();
  String? selectedSorting;
  List<Client> clients = [];
  StatusFilter currentFilter = StatusFilter.all;
  bool notFoundOnSearch = false;
  bool isLoading = false;
  var sortingChoices = [
    'Modification time',
    'Name',
  ];

  @override
  void initState() {
    getClients(); // Fetch clients when the widget initializes
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          currentFilter = StatusFilter.all;
          break;
        case 1:
          currentFilter = StatusFilter.localClients;
          break;
      }
      getClients(filter: currentFilter, sort: selectedSorting);
    });
  }

//mapping data to list
  Future<void> getClients(
      {StatusFilter filter = StatusFilter.all, String? sort}) async {
    String query;

    switch (filter) {
      case StatusFilter.localClients:
        query = """
  SELECT * FROM clients 
WHERE COALESCE(address, '') <> ''
""";
        break;

      default:
        query = """
  SELECT * FROM clients 
""";
    }

    try {
      var data = await sqlHelper.db!.rawQuery(query);
      if (data.isNotEmpty) {
        clients = data.map((item) => Client.fromJson(item)).toList();
      } else {
        clients = [];
      }
      if (sort != null) {
        applySorting(sort);
      }
    } catch (e) {
      print('Error in getting Clients: $e');
    }
    setState(() {});
  }

  void applySorting(String sort) {
    switch (sort) {
      case 'Name':
        clients.sort((a, b) => a.name!.compareTo(b.name!));
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: ('Clients'),
          sortingChoices: sortingChoices,
          onSelected: (String choice) async {
            if (choice == 'Sort by') {
              showMenu<String>(
                constraints:
                    const BoxConstraints.expand(width: 180, height: 110),
                surfaceTintColor: Colors.white,
                context: context,
                position: const RelativeRect.fromLTRB(double.infinity, 0, 0, 0),
                items: sortingChoices.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(item),
                    ),
                  );
                }).toList(),
              ).then((String? value) {
                if (value != null) {
                  setState(() {
                    selectedSorting = value;
                  });
                  getClients(filter: currentFilter, sort: value);
                }
              });
            } else if (choice == 'Refresh') {
              setState(() {
                isLoading = true; // Show the loading indicator
              });

              // Introduce a delay before calling the function
              await Future.delayed(Duration(milliseconds: 600));
              await getClients(filter: currentFilter, sort: selectedSorting);

              // Hide the loading indicator
              setState(() {
                isLoading = false;
              });
            }
          },
          Controller: _tabController,
          tabs: [Tab(text: 'All'), Tab(text: 'Local Clients')],
          searchLabel: 'Search For any Client',
          onSearchTextChanged: (text) async {
            if (text.isEmpty) {
              getClients();
              return;
            }

            //search the data for the text provided
            final data = await sqlHelper.db!.rawQuery('''
                      SELECT * FROM clients 
                      WHERE name LIKE '%$text%'
                      OR address LIKE '%$text%'
                      OR email LIKE '$text'
                    ''');

            //if anything related found, map it to a list
            if (data.isNotEmpty) {
              clients = data.map((item) => Client.fromJson(item)).toList();

              //nothing found? empty list
            } else {
              clients = [];
            }
            setState(() {});
          },
        ),
        body: clients.isEmpty
            ? notFoundOnSearch
                ? const SizedBox()
                : const Center(
                    child: Text('No Clients Found'),
                  )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          )
                        : SizedBox(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            print('Client: ${client.name}');

                            //caling listcard
                            return MyCard(
                              onDeleted: () => onDeleteClient(client),
                              onEdit: () {
                                slideRightWidget(
                                    newPage: ClientsOpsPage(client: client),
                                    context: context);
                              },
                              name: client.name!,
                              customWidget: Column(
                                children: [
                                  ClientsInfo(
                                      label: client.address!,
                                      icon: Icons.home,
                                      width: 357),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ClientsInfo(
                                          label: client.phone!,
                                          icon: Icons.phone,
                                          width: 156),
                                      SizedBox(width: 10),
                                      ClientsInfo(
                                          label: client.email!,
                                          icon: Icons.email,
                                          width: 156),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            var updated = await pushWidgetAwait(
              newPage: const ClientsOpsPage(),
              context: context,
            );
            if (updated == true) {
              getClients();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  //Deleting product
  Future<void> onDeleteClient(Client client) {
    //Callling itemDeleted dialog
    return showDialog(
        context: context,
        builder: (context) {
          return MyItemDeletedDialog(
              item: client.name,
              onDeleteditem: () async {
                await sqlHelper.db!
                    .delete('products', where: 'id =?', whereArgs: [client.id]);
                getClients();
              });
        });
  }
}
