import 'package:expanses/Failure.dart';
import 'package:expanses/budget_repository.dart';
import 'package:expanses/pi_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'item_model.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notion Expanse Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: const BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItem;
  @override
  void initState() {
    super.initState();
    _futureItem = BudgetRepository().getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItem = BudgetRepository().getItem();
          setState(() {});
        },
        child: FutureBuilder<List<Item>>(
          future: _futureItem,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // show pi char and list of item
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return SpendingChart(items: items);
                  final item = items[index - 1];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            width: 2.0, color: getCategoryColor(item.category)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0)
                        ]),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          '${item.category} • ${DateFormat.yMd().format(item.date)}'),
                      trailing: Text(
                        "Rs. " + item.price.toString(),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Show failure error message.
              final failure = snapshot.error as Failure;
              return Center(child: Text(failure.message));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Food 🍕':
      return Colors.red[400]!;
    case 'Travel 🚐':
      return Colors.green[400]!;
    case 'Fule ⛽':
      return Colors.blue[400]!;
    case 'Entertenment 🥳':
      return Colors.purple[400]!;
    case 'Mobile Recharge📱':
      return Colors.green[400]!;
    case 'Other bill 🗒':
      return Colors.red[400]!;
    case 'Education 📕':
      return Colors.pink[400]!;
    case 'Shopping 🛍':
      return Colors.red[200]!;
    case 'General 🦉':
      return Colors.yellow[200]!;
    default:
      return Colors.orange[600]!;
  }
}
