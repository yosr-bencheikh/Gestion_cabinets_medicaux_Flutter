import 'package:flutter/material.dart';
import 'package:doctor_appointment/constants.dart';
import 'package:doctor_appointment/Custom_appbar.dart';
import 'package:doctor_appointment/successPage.dart';

import 'bookingPage.dart';

class DoctorDetails extends StatefulWidget {
  final String doctorId;
  final String doctorImagePath;
  final String doctorName;
  final String doctorProfession;
  final String doctorHospital;
  final String doctorAddress;
  final String doctorStudies;
  final String doctorPhone;
  final String doctorHours;

  const DoctorDetails({
    Key? key,
    required this.doctorId,
    required this.doctorImagePath,
    required this.doctorName,
    required this.doctorProfession,
    required this.doctorHospital,
    required this.doctorAddress,
    required this.doctorStudies,
    required this.doctorPhone,
    required this.doctorHours,
  }) : super(key: key);

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          appTitle: 'Doctor Details',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      widget.doctorImagePath,
                      width: 120,
                      height: 120,
                    ),
                  ),
                  smallBox,
                  Text(
                    widget.doctorName,
                    style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  smallBox,
                  Text(
                    'Specialised in ${widget.doctorProfession}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  smallBox,
                  SizedBox(
                    height: 70,
                    child: Text(
                      widget.doctorStudies,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width ,
                    child: Text(
                     'Hospital : ${widget.doctorHospital}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  smallBox,
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        NewWidget(label: 'Address', value: widget.doctorAddress),
                        widthSpace,
                        NewWidget(label: 'Hours', value: widget.doctorHours),
                        widthSpace,
                        NewWidget(label: 'Phone', value: widget.doctorPhone),
                      ],
                    ),
                  ),
                  smallBox,
                  smallBox,
                  Text(
                    'Does this doctor meet your needs ? ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  smallBox,
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            doctorId: widget.doctorId, // Pass the doctor's ID
                          ),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      primary: prColor,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Book an appointment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: prColor,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 15,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
