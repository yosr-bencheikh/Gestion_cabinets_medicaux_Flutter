import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'doctorDetails.dart';

class DoctorList extends StatelessWidget {
  final String doctorId;
  final int rating;
  final String doctorImagePath;
  final String doctorName;
  final String doctorProfession;
  final String doctorHospital;
  final String doctorAddress;
  final String doctorPhone;
  final String doctorStudies;
  final int doctorExperienceYears;
  final String doctorHours;

  const DoctorList({
    Key? key,
    required this.doctorId,
    required this.rating,
    required this.doctorImagePath,
    required this.doctorName,
    required this.doctorProfession,
    required this.doctorExperienceYears,
    required this.doctorHospital,
    required this.doctorAddress,
    required this.doctorPhone,
    required this.doctorStudies,
    required this.doctorHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetails(
              doctorId: doctorId,
              doctorProfession: doctorProfession,
              doctorImagePath: doctorImagePath,
              doctorAddress: doctorAddress,
              doctorHospital: doctorHospital,
              doctorName: doctorName,
              doctorPhone: doctorPhone,
              doctorStudies: doctorStudies,
              doctorHours: doctorHours,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 15),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: prColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Image.network(
                  doctorImagePath ?? 'default_avatar_image_path',
                  width: 70,
                  height: 70,
                ),
              ),
              smallBox,
              buildRow(),
              smallBox,
              Text(
                doctorName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(doctorProfession),
              Text('$doctorExperienceYears years of experience'),
            ],
          ),
        ),
      ),
    );
  }

  Row buildRow() {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Column(
            children: [
              if (i < rating)
                Icon(
                  Icons.star,
                  color: Colors.yellow[500],
                )
              else
                Icon(
                  Icons.star,
                  color: Colors.grey[500],
                ),
            ],
          ),
      ],
    );
  }
}
