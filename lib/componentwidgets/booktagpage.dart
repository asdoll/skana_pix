import 'package:flutter/material.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage> {
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
        title: Text('Book Tags'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Tag $index'),
            subtitle: Text('Books: 10'),
            trailing: Icon(Icons.book),
          );
        },
      ),
    );
  }
}

class MyIllustTags extends StatefulWidget {
  @override
  _MyIllustTagsState createState() => _MyIllustTagsState();
}

class _MyIllustTagsState extends State<MyIllustTags>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}