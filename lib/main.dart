import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/widgets/chart.dart';
import 'package:flutter_course/widgets/new_transaction.dart';
import 'package:flutter_course/widgets/transaction_list.dart';

import 'models/transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(secondary: Colors.amber),
        fontFamily: 'Quicksand',
        textTheme: ThemeData
            .light()
            .textTheme
            .copyWith(
          headline6: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          button: const TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];
  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String txTitle, double txAmount,
      DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext bCtx) => NewTransaction(addTx: _addNewTransaction),
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(double appHeight, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Show Chart',
            style: Theme
                .of(context)
                .textTheme
                .headline6,
          ),
          Switch.adaptive(
            activeColor: Theme
                .of(context)
                .colorScheme
                .secondary,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? SizedBox(
        height: appHeight * 0.7,
        child: Chart(recentTransactions: _recentTransactions),
      )
          : txListWidget,
    ];
  }

  List<Widget> _buildPortraitContent(double appHeight, Widget txListWidget) {
    return [
      SizedBox(
        height: appHeight * 0.3,
        child: Chart(recentTransactions: _recentTransactions),
      ),
      txListWidget
    ];
  }

  CupertinoNavigationBar _buildIosAppBar() {
    return CupertinoNavigationBar(
      middle: const Text('Personal Expenses'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: const Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context),
          )
        ],
      ),
    );
  }

  AppBar _buildAndroidAppBar() {
    return AppBar(
      centerTitle: false,
      title: const Text('Personal Expenses'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final iosAppBar = _buildIosAppBar();
    final androidAppBar = _buildAndroidAppBar();
    final preferredSize =
    Platform.isIOS ? iosAppBar.preferredSize : androidAppBar.preferredSize;
    final appHeight =
        mediaQuery.size.height - preferredSize.height - mediaQuery.padding.top;
    final txListWidget = SizedBox(
      height: appHeight * 0.7,
      child: TransactionList(
        transactions: _userTransactions,
        deleteTx: _deleteTransaction,
      ),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandscape)
              ..._buildLandscapeContent(
                appHeight,
                txListWidget,
              ),
            if (!isLandscape)
              ..._buildPortraitContent(
                appHeight,
                txListWidget,
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
      navigationBar: iosAppBar,
      child: pageBody,
    )
        : Scaffold(
      appBar: androidAppBar,
      body: pageBody,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
