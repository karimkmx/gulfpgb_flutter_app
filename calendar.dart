import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gulfpgb/screens//event.dart';
import 'package:shared_preferences/shared_preferences.dart';

const IconData notes = IconData(0xe44c, fontFamily: 'MaterialIcons');


class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<Event>> selectedEvents;
  Map<DateTime, List<dynamic>> dynamicSelectedEvents;

  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    selectedEvents = {};
    dynamicSelectedEvents = {};
    _getStoredEvents();
    super.initState();
  }

  Future<void> _getStoredEvents() async {
    final pref = await SharedPreferences.getInstance();

    //
    String encodedMap = pref.getString('timeData');
    Map<String,dynamic> decodedMap = json.decode(encodedMap);
    print(decodedMap);



    final storedEvents = pref.getString("allEvents");
    print("Inside getStoredEvents");

    setState(() {
      dynamicSelectedEvents = Map<DateTime, List<dynamic>>.from(
          decodeMap(jsonDecode(pref.getString("allEvents") ?? "{}")));

    });
    dynamicSelectedEvents.forEach((key, value) {
      print(dynamicSelectedEvents[key]);
      //selectedEvents[key] = dynamicSelectedEvents[key];
      List<Event> events =  [];
      dynamicSelectedEvents[key].forEach((element) {
        print("Adding element: " + element.toString());
        events.add(Event(title: element.toString()));
      });
      print("Adding event: " + events.toString());
      selectedEvents[key] = events;
    });
    /*
    if(storedEvents == null){
      print("storedEvents is empty");
      selectedEvents = {};
      return null;
    }
    print("storedEvents: " + storedEvents);
    Map<DateTime, List<Event>> allEvents = json.decode(storedEvents);
    selectedEvents = allEvents;
    return null;

     */
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime,  dynamic> newMap = {};
    map.forEach((key, value) {
      print(map[key]);
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }
  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
      print("EncodeMap");
      print(map[key]);
      //dprint(map[value]);
      //print(newMap[key.toString()]);
    });
    return newMap;
  }


  Future<void> _storeEvents() async {
    final pref = await SharedPreferences.getInstance();
    //
    Map<String, dynamic> selectedTimes = {
      "Pomodoro Setting": 15,
      "Rest Time Setting": 5,
      "Long Rest Time Setting": 15,
      "Term of Resting Time Setting": 5
    };
    var encodedMap = json.encode(selectedTimes);
    print(encodedMap);

    pref.setString('timeData', encodedMap);

    pref.setString("allEvents", json.encode(encodeMap(dynamicSelectedEvents)));

    //
    //String str = selectedEvents.cast().toString();
    //var s = json.encode(str);
    print("INSIDE _storeEvents:");
    //print("selectedEvents: " + s);
    //pref.setString("allEvents", s);

  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("GULFPGR Calendar Notes"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(

              focusedDay: selectedDay,
              firstDay: DateTime(1990),
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format) {
                setState(() {
                  format = _format;
                });
              },
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,

              //Day Changed
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                });
                print(focusedDay);
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },

              eventLoader: _getEventsfromDay,

              //To style the Calendar
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 15,),
            ..._getEventsfromDay(selectedDay).map(
                  (Event event) =>
                  Card(
                    color: Colors.amber,
                    elevation: 2,
                    child:
                    Row(

                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Expanded( flex: 8,
                          child:

                          ListTile(
                            leading: Icon(notes),
                            //trailing: Icon(Icons.delete),
                            title: Text(
                              event.title,
                            ),
                            onTap: (){
                              print(selectedEvents[selectedDay].toString() + " " + selectedEvents.toString() + " " +
                                  "");
                              print('${event.title}');
                              //selectedEvents[selectedDay].remove(event);
                            },
                            onLongPress: () {
                              print("This is a long press");
                            },
                          ),
                        ),
                        /*
                    Expanded( child:
                    IconButton(
                      iconSize: 24,
                      icon: const Icon(Icons.edit,size: 24.0,),
                      color: Colors.black45,
                      onPressed: () {
                        print("Edit Button");
                      },
                    ),
                    ),*/
                        Expanded( child:
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.delete,size: 24.0,),
                          color: Colors.black,
                          onPressed: () {
                            print("Delete Button");

                            setState(() {
                              var index = 0;
                              selectedEvents[selectedDay].forEach((element) {

                                 if(element == event) {
                                   dynamicSelectedEvents[selectedDay].removeAt(index);
                                 }
                                 index++;
                              });
                              selectedEvents[selectedDay].remove(event);
                              _storeEvents();
                              _getStoredEvents();
                            });
                          },
                        ),

                        ),
                        // Image.asset('images/pic2.jpg'),
                        //  Image.asset('images/pic3.jpg'),
                      ],
                    ),
                  ),
            ),

          ],
        ),


      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Add Note"),
            content: TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: null,
              controller: _eventController,
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  if (_eventController.text.isEmpty) {

                  } else {
                    if (selectedEvents[selectedDay] != null) {
                      selectedEvents[selectedDay].add(
                        Event(title: _eventController.text),
                      );
                      //dynamicSelectedEvents[selectedDay] = selectedEvents[selectedDay];
                      dynamicSelectedEvents[selectedDay].add(_eventController.text);
                      _storeEvents();
                      _getStoredEvents();
                    } else {
                      selectedEvents[selectedDay] = [
                        Event(title: _eventController.text)
                      ];
                      //dynamicSelectedEvents[selectedDay] = selectedEvents[selectedDay];
                      dynamicSelectedEvents[selectedDay] = [_eventController.text.toString()];
                      _storeEvents();
                      _getStoredEvents();

                    }

                  }
                  Navigator.pop(context);
                  _eventController.clear();
                  setState((){});
                  return;
                },
              ),
            ],
          ),
        ),

        label: Text("Add Note"),
        icon: Icon(Icons.add),
      ),
    );
  }
}