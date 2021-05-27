import 'package:barber_booking/cloud_firestore/all_salon_ref.dart';
import 'package:barber_booking/model/barber_model.dart';
import 'package:barber_booking/model/city_model.dart';
import 'package:barber_booking/model/salon_model.dart';
import 'package:barber_booking/state/state_management.dart';
import 'package:barber_booking/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var barberWatch = watch(selectedBarber).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFDF9EE),
      body: Column(
        children: [
          //step
          NumberStepper(
            activeStep: step - 1,
            direction: Axis.horizontal,
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            numbers: [1, 2, 3, 4, 5],
            stepColor: Colors.black,
            activeStepColor: Colors.blue,
            numberStyle: TextStyle(color: Colors.white),
          ),
          //Screen
          Expanded(
              flex: 10,
              child: step == 1
                  ? displayCityList()
                  : step == 2
                      ? displaySalon(cityWatch.name)
                      : step == 3
                          ? displayBarber(salonWatch)
                          : step == 4
                              ? displayTimeSlot(context, barberWatch)
                              : Container()),
          //button
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    child: Text('Previous'),
                    onPressed: step == 1
                        ? null
                        : () => context.read(currentStep).state--,
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    child: Text('Next'),
                    //disable button next if nothing is selected
                    onPressed: (step == 1 &&
                                context.read(selectedCity).state.name ==
                                    null) ||
                            (step == 2 &&
                                context.read(selectedSalon).state.docId ==
                                    null) ||
                            (step == 3 &&
                                context.read(selectedBarber).state.docId ==
                                    null) ||
                            (step == 4 &&
                                context.read(selectedTimeSlot).state == -1)
                        ? null
                        : step == 5
                            ? null
                            : () => context.read(currentStep).state++,
                  )),
                ],
              ),
            ),
          ))
        ],
      ),
    ));
  }

  displayCityList() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var cities = snapshot.data as List<CityModel>;
            if (cities == null || cities.length == 0) {
              return Center(
                child: Text('Cannot load city list'),
              );
            } else {
              return ListView.builder(
                itemCount: cities.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedCity).state = cities[index],
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.home_work,
                          color: Colors.black,
                        ),
                        trailing: context.read(selectedCity).state.name ==
                                cities[index].name
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          '${cities[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displaySalon(String cityName) {
    return FutureBuilder(
        future: getSalonByCity(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var salons = snapshot.data as List<SalonModel>;
            if (salons == null || salons.length == 0) {
              return Center(
                child: Text('Cannot load salon list'),
              );
            } else {
              return ListView.builder(
                itemCount: salons.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedSalon).state = salons[index],
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.home_outlined,
                          color: Colors.black,
                        ),
                        trailing: context.read(selectedSalon).state.docId ==
                                salons[index].docId
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          '${salons[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                        subtitle: Text(
                          '${salons[index].address}',
                          style: GoogleFonts.robotoMono(
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displayBarber(SalonModel salonWatch) {
    return FutureBuilder(
        future: getBarberBySalon(salonWatch),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var barbers = snapshot.data as List<BarberModel>;
            if (barbers == null || barbers.length == 0) {
              return Center(
                child: Text('Cannot load barber list'),
              );
            } else {
              return ListView.builder(
                itemCount: barbers.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedBarber).state = barbers[index],
                    child: Card(
                      child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          trailing: context.read(selectedBarber).state.docId ==
                                  barbers[index].docId
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${barbers[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                          subtitle: RatingBar.builder(
                            itemSize: 16,
                            allowHalfRating: true,
                            initialRating: barbers[index].rating,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemPadding: const EdgeInsets.all(4),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          )),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displayTimeSlot(BuildContext context, BarberModel barberModel) {
    var now = DateTime.now();
    var selected = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                        Text(
                          "${DateFormat.MMMM().format(selected)}",
                          style: GoogleFonts.robotoMono(color: Colors.white54),
                        ),
                      Text(
                        "${selected.day}",
                        style: GoogleFonts.robotoMono(color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                      ),
                      Text(
                        "${DateFormat.EEEE().format(selected)}",
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )),
              GestureDetector(
                onTap: (){
                  DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: now,
                    maxTime: now.add(Duration(days: 31)),
                    onConfirm: (date) => context.read(selectedDate).state = date
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.calendar_today, color: Colors.white,),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(child: GridView.builder(
        itemCount: TIME_SLOT.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5
            ),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                context.read(selectedTime).state = TIME_SLOT.elementAt(index);
              },
              child: Card(
                color: context.read(selectedTime).state == TIME_SLOT.elementAt(index) ? Colors.greenAccent : Colors.white,
                child: GridTile(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Text("${TIME_SLOT.elementAt(index)}"),
                          Text("Available"),
                      ],
                    ),
                  ),
                  header: context.read(selectedTime).state == TIME_SLOT.elementAt(index) ? Icon(Icons.check) : null,
                ),
              ),
            )
        ))
      ],
    );
  }
}
