import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'event_detail_page.dart';

class Event {
  final String title;
  final String content;
  final String imageUrl;

  Event({required this.title, required this.content, required this.imageUrl});
}

class DisplayEventsPage extends StatefulWidget {
  @override
  _DisplayEventsPageState createState() => _DisplayEventsPageState();
}

class _DisplayEventsPageState extends State<DisplayEventsPage> {
  late List<Event> _events;
  late List<Event> _filteredEvents;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = [];
    _filteredEvents = [];
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://192.168.32.1:800/events/'));
    if (response.statusCode == 200) {
      final List<dynamic> eventData = jsonDecode(response.body);
      setState(() {
        _events = eventData.map((event) {
          return Event(
            title: event['title'],
            content: event['content'],
            imageUrl: event['image'],
          );
        }).toList();
        _filteredEvents = List.from(_events);
      });
    } else {
      // Handle error
      print('Failed to load events');
    }
  }

  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = _events.where((event) {
        final titleLower = event.title.toLowerCase();
        final contentLower = event.content.toLowerCase();
        final queryLower = query.toLowerCase();

        return titleLower.contains(queryLower) ||
            contentLower.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterEvents,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          title: _filteredEvents[index].title,
                          content: _filteredEvents[index].content,
                          imageUrl: _filteredEvents[index].imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(_filteredEvents[index].imageUrl),
                        SizedBox(height: 8.0),
                        Text(
                          _filteredEvents[index].title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          _filteredEvents[index].content,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
