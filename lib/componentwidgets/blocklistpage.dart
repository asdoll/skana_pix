import 'package:flutter/material.dart';

class BlockListPage extends StatefulWidget {
  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: ScrollableState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Users'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('User $index'),
            subtitle: Text('Blocked'),
            trailing: Icon(Icons.block),
          );
        },
      ),
    );
  }
}