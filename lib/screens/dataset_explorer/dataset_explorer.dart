import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main/components/header.dart';


class DatasetExplorer extends StatefulWidget {
  const DatasetExplorer({super.key});

  @override
  _DatasetExplorerState createState() => _DatasetExplorerState();
}

class _DatasetExplorerState extends State<DatasetExplorer> {
  int highCount = 0;
  int lowCount = 0;
  final int batchSize = 30;
  final List<String> classes = <String>['Unknown', 'Carcinoma', 'Necrosis', 'Tumor Stroma', 'Others'];
  List<int> highLoadedIndices = <int>[];
  List<int> lowLoadedIndices = <int>[];
  late ScrollController _scrollController;
  bool isCompactView = false;
  
  @override
  void initState() {
    super.initState();
    _fetchCounts();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCounts() async {
    final http.Response highResponse = await http.get(Uri.parse('https://microcosm-backend.gmichele.com/high/count'));
    final http.Response lowResponse = await http.get(Uri.parse('https://microcosm-backend.gmichele.com/low/count'));

    if (highResponse.statusCode == 200 && lowResponse.statusCode == 200) {
      final highData = json.decode(highResponse.body);
      final lowData = json.decode(lowResponse.body);

      setState(() {
        highCount = highData['rows'][0][0] as int;
        lowCount = lowData['rows'][0][0] as int;
        highLoadedIndices = List.generate(batchSize < highCount ? batchSize : highCount, (int index) => index + 1);
        lowLoadedIndices = List.generate(batchSize < lowCount ? batchSize : lowCount, (int index) => index + 1);
      });
    } else {
      print('Failed to load counts');
    }
  }

  Future<List<String>> _fetchImage(String type, int id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final http.Response imageResponse = await http.get(Uri.parse('https://microcosm-backend.gmichele.com/get/$type/$id/image'));
    final http.Response cmapResponse = await http.get(Uri.parse('https://microcosm-backend.gmichele.com/get/$type/$id/cmap'));

    if (imageResponse.statusCode == 200 && cmapResponse.statusCode == 200) {
      final imageData = json.decode(imageResponse.body);
      final cmapData = json.decode(cmapResponse.body);

      return <String>[imageData['rows'][0][0] as String, cmapData['rows'][0][0] as String];
    } else {
      print('Failed to load images');
      return <String>['', 'Failed to load images'];
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      _loadMoreImages();
    }
  }

  void _loadMoreImages() {
    setState(() {
      if (highLoadedIndices.length < highCount) {
        int nextBatchEnd = highLoadedIndices.length + batchSize < highCount
            ? highLoadedIndices.length + batchSize
            : highCount;
        highLoadedIndices.addAll(List.generate(nextBatchEnd - highLoadedIndices.length, (int index) => highLoadedIndices.length + index + 1));
      }
      if (lowLoadedIndices.length < lowCount) {
        int nextBatchEnd = lowLoadedIndices.length + batchSize < lowCount
            ? lowLoadedIndices.length + batchSize
            : lowCount;
        lowLoadedIndices.addAll(List.generate(nextBatchEnd - lowLoadedIndices.length, (int index) => lowLoadedIndices.length + index + 1));
      }
    });
  }

  List<PieChartSectionData> _createPieChartData() {
    final double sectionValue = (highCount + lowCount) / classes.length;

    return classes.asMap().entries.map((MapEntry<int, String> entry) {
      final int index = entry.key;
      final String className = entry.value;

      return PieChartSectionData(
        color: _getColor(index),
        value: sectionValue,
        title: className,
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildImageCard(String type, int id) {
    return FutureBuilder<List<String>>(
      future: _fetchImage(type, id),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'ID: $id',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Oops! Something went wrong.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'Failed to load images.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else {
          final List<String>? images = snapshot.data;
          if (isCompactView) {
            // Compact view: Images and cmap side by side
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Image.memory(base64Decode(images![0]), height: 250),
                        Image.memory(base64Decode(images[1]), height: 250),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID: $id',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Default view: Larger images stacked vertically
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'ID: $id',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Image.memory(base64Decode(images![0])),
                    const SizedBox(height: 10),
                    Image.memory(base64Decode(images[1])),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Dataset Explorer',),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: () {
              setState(() {
                isCompactView = !isCompactView;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  'Remote Dataset Explorer',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Low image count:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(
                            text: ' $lowCount',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'High image count:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(
                            text: ' $highCount',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Total image count:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(
                            text: ' ${lowCount + highCount}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Classes available:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(
                            text: ' ${classes.join(', ')}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(8),
                  child: PieChart(
                    PieChartData(
                      sections: _createPieChartData(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('High Resolution Images', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Column(
                children: highLoadedIndices.map((int index) => _buildImageCard('high', index)).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Low Resolution Images', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Column(
                children: lowLoadedIndices.map((int index) => _buildImageCard('low', index)).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _fetchCounts,
                  child: const Text('Reload Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String className;
  final int count;

  ChartData(this.className, this.count);
}