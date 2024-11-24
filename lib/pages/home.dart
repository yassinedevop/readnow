import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/pages/statistics.dart';
import 'package:readnow/utils/widgets/preview_page/continue_reading.dart';
import 'package:readnow/utils/widgets/preview_page/most_read.dart';
import 'package:readnow/pages/categories.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    CategoriesPage(),
    StatisticsPage(), // Add this line
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Read Now', style: Theme.of(context).textTheme.displayLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<DocumentBloc>().add(ClearCache());
            },
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          showSelectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics', // Add this line
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).highlightColor,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).cardColor.withOpacity(0.8),
          elevation: 4,
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DocumentBloc>().add(LoadDocuments());
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ContinueReading(lastDocumentRead: state.lastReadDocument!),
                  MostReadBooks(documents: state.documents),
                ],
              ),
            ),
          );
        } else if (state is DocumentLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text('Failed to load documents'));
        }
      },
    );
  }
}
