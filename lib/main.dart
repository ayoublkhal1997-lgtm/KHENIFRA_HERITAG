import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() => runApp(const KhenifraHeritageApp());

class KhenifraHeritageApp extends StatelessWidget {
  const KhenifraHeritageApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تراث خنيفرة',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), 
      ),
      home: const HeritageListScreen(),
    );
  }
}

class HeritageListScreen extends StatefulWidget {
  const HeritageListScreen({super.key});
  @override
  _HeritageListScreenState createState() => _HeritageListScreenState();
}

class _HeritageListScreenState extends State<HeritageListScreen> {
  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, "atlas_maroc.db");

      ByteData data = await rootBundle.load(join("assets", "atlas_maroc.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);

      Database db = await openDatabase(path);
      List<Map<String, dynamic>> list = await db.query('heritage_sites');
      
      setState(() {
        _sites = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("دليل تراث إقليم خنيفرة"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sites.isEmpty
              ? const Center(child: Text("لم يتم العثور على بيانات"))
              : ListView.builder(
                  itemCount: _sites.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.account_balance, color: Colors.brown),
                        title: Text(
                          _sites[index]['SITE_NAME'] ?? 'موقع غير مسمى',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_sites[index]['CATEGORY'] ?? 'تصنيف عام'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}