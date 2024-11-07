import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickPage extends StatefulWidget {
  final Color initialColor;

  ColorPickPage({required this.initialColor});

  @override
  _ColorPickPageState createState() => _ColorPickPageState();
}

class _ColorPickPageState extends State<ColorPickPage> {
  late Color pickerColor;
  @override
  void initState() {
    pickerColor = widget.initialColor;
    super.initState();
  }

  final skinList = [
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.cyan[500],
      indicatorColor: Colors.cyan[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.pink[500],
      indicatorColor: Colors.pink[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green[500],
      indicatorColor: Colors.green[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.brown[500],
      indicatorColor: Colors.brown[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.purple[500],
      indicatorColor: Colors.purple[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue[500],
      indicatorColor: Colors.blue[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFFB7299),
      indicatorColor: Color(0xFFFB7299),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick A Color".i18n),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final TextEditingController textEditingController =
                    TextEditingController(
                        text: pickerColor.value
                            .toRadixString(16)
                            .toLowerCase()
                            .replaceFirst('ff', ''));

                String result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("16 radix RGB".i18n),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        content: TextField(
                          controller: textEditingController,
                          maxLength: 6,
                          decoration: InputDecoration(
                              prefix: Text("${"Color".i18n}(0xff"),
                              suffix: Text(")")),
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                final result = textEditingController.text
                                    .trim()
                                    .toLowerCase();
                                if (result.length != 6) {
                                  return;
                                }
                                Navigator.of(context)
                                    .pop("${"Color".i18n}(0xff${result})");
                              },
                              child: Text("Ok".i18n)),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel".i18n)),
                        ],
                      );
                    });
                Color color = _stringToColor(result); //迅速throw出来
                setState(() {
                  pickerColor = color;
                });
              }),
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(pickerColor);
              })
        ],
      ),
      body: LayoutBuilder(builder: (context, snapshot) {
        final rowCount = max(3, (snapshot.maxWidth / 200).floor());
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorPicker(
                  enableAlpha: false,
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      pickerColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
            ),
            SliverGrid.count(
              crossAxisCount: rowCount,
              children: [
                for (final i in skinList)
                  InkWell(
                    onTap: () {
                      setState(() {
                        pickerColor = i.primaryColor;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: i.primaryColor,
                      ),
                    ),
                  )
              ],
            )
          ],
        );
      }),
    );
  }

  Color _stringToColor(String colorString) {
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    return otherColor;
  }
}

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Skin".i18n),
            bottom: TabBar(
                controller: TabController(
                  length: 3,
                  initialIndex: ThemeMode.values.indexOf(settings.themeMode),
                  vsync: this,
                ),
                onTap: (i) {
                  settings.setThemeMode(i);
                },
                tabs: [
                  Tab(
                    text: "System".i18n,
                  ),
                  Tab(
                    text: "Light".i18n,
                  ),
                  Tab(
                    text: "Dark".i18n,
                  ),
                ])),
        body: Observer(builder: (_) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                    child: SwitchListTile(
                  value: settings.isAMOLED,
                  onChanged: (v) {setState(() {
                    settings.set("isAMOLED",v);
                  });},
                  title: const Text("AMOLED"),
                )),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: SwitchListTile(
                  value: settings.useDynamicColor,
                  onChanged: (v) async {
                    setState(() {
                      settings.set("useDynamicColor",v);
                    });
                  },
                  title: Text("Dynamic Color".i18n),
                )),
              ),
              if (!settings.useDynamicColor)
                SliverToBoxAdapter(
                  child: Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(settings.seedColor),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      title: Text("Seed Color".i18n),
                      onTap: () {
                        _pickColor();
                      },
                    ),
                  ),
                )
            ],
          );
        }),
      );
    });
  }

  _pickColor() async {
    Color? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ColorPickPage(initialColor: Color(settings.seedColor))));
    if (result != null) {
      setState(() {
        settings.set("seedColor", result.value);
      });
    }
  }
}
