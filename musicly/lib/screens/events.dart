import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musicly/screens/addevent.dart';
import 'package:musicly/theme/theme.dart';
import 'package:musicly/utils/constants.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> allEvents = [];

  @override
  void initState() {
    getAllEvents();
    super.initState();
  }

  void getAllEvents() async {
    final result = await FirebaseFirestore.instance.collection('events').get();
    if (result.docs.isNotEmpty) {
      var resultData = result.docs;
      allEvents = [];
      for (var event in resultData) {
        Map<String, dynamic> eventData = event.data();
        eventData['id'] = event.id;
        allEvents.add(eventData);
      }
      setState(() {
        allEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: buildEventsList(),
      floatingActionButton: buildActionButton(),
    );
    // return Stack(children: [
    //   Positioned(
    //     bottom: 100.0,
    //     right: 0.0,
    //     child: buildActionButton(),
    //   ),
    //   buildEventsList(),
    // ]);
  }

  Widget buildEventsList() {
    if (allEvents.isEmpty) {
      return const Center(
        child: Text("No Events FOund"),
      );
    }
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var event in allEvents) buildEventCard(event),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  Widget buildEventCard(event) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: Column(
        children: [
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                image: DecorationImage(
                    image: NetworkImage(event['file']), fit: BoxFit.cover)),
            child: Text(event['name']),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.white.withOpacity(0.5)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Event Name: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(event['name']),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Event On: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(event['eventon'].toDate().toString()),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Event Details: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(event['description']),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildActionButton() {
    if (userRole == 'admin') {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEvent(),
            ),
          );
        },
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 10, bottom: 100),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: lightColorScheme.primary.withOpacity(0.8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Event",
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Icon(
                Icons.event_note,
                color: Colors.white,
                size: 30,
              )
            ],
          ),
        ),
      );
    }
    return Container();
  }
}
