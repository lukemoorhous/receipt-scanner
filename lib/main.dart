import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:receipt/DateRangeSelection.dart';
import 'package:receipt/EditEntry.dart';

import 'package:receipt/data/db.dart';
import 'package:receipt/data/receipt.dart';
import 'package:receipt/ImagePickerModal.dart';
import './pages/report_pages.dart';
import 'package:receipt/ManualEntry.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Receipt Scanner'),
      routes: {
        '/': (context) => MyHomePage(title: 'Receipt Scanner'),
        '/parsePreview': (context) => ParsePreview(),
        '/manualEntry': (context) => ManualEntryPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Receipt>> _receipts;

  @override
  void initState() {
    super.initState();
    _receipts = _fetch();
    print(_receipts);
  }

  Future<List<Receipt>> _fetch() {
    return receiptAPI.getAllReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ExpansionTile(
              title: Text("Reports"),
              children: <Widget>[
                ListTile(
                    title: Text("Recent Receipts"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new Report_pages("recent", 0, 0)))),
                ListTile(
                    title: Text("This Month"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new Report_pages("month", 0, 0)))),
                ListTile(
                    title: Text("This Year"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new Report_pages("year", 0, 0)))),
                ListTile(
                    title: Text("Custom Range"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (context) => DateRangeSelection()))),
              ],
            ),
            ExpansionTile(
              title: Text("Budgeting"),
              children: <Widget>[
                ListTile(
                  title: Text("Placeholder"),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ],
            )
          ],
        ),
      ),
      body: FutureBuilder<List<Receipt>>(
        future: _fetch(),
        builder: (BuildContext context, AsyncSnapshot<List<Receipt>> snapshot) {
          if (snapshot.hasData) {
            final length = snapshot.data.length;
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: length,
              itemBuilder: (BuildContext context, int index) {
                final Receipt item = snapshot.data[index];

                final DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(item.receiptDate);
                final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
                final formatCurrency = new NumberFormat.simpleCurrency();

                return
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new EditEntryPage(receipt: item))),
                  child:
                  Card(
                  child: Container(
                  height: 55,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            '${item.id}: ${formatCurrency.format(item.total / 100)} - ${dateFormat.format(date)}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => ImagePickerModal(),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
