// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

import '../Details_Screen/detail_screen.dart';

class AllTourPlaces extends StatefulWidget {
  @override
  State<AllTourPlaces> createState() => _AllTourPlacesState();
}

class _AllTourPlacesState extends State<AllTourPlaces> {
  late Stream<List<QueryDocumentSnapshot>> streamsCombined;

  @override
  void initState() {
    super.initState();
    streamsCombined = CombineLatestStream.list([
      FirebaseFirestore.instance.collection('all-hill').snapshots(),
      FirebaseFirestore.instance.collection('all-sea').snapshots(),
      FirebaseFirestore.instance.collection('all-park').snapshots(),
      // Add more streams here if needed
    ]).map((List<QuerySnapshot> snapshots) {
      // Combine the query snapshots from different collections
      return snapshots.expand((snapshot) => snapshot.docs).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: streamsCombined,
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        List<QueryDocumentSnapshot> documents = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = documents[index];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            var name = data['name'];
            var description = data['description'];
            var location = data['location'];
            var duration = data['duration'];
            var rating = data['rating'];
            var imageList = data['image_list'] as List<dynamic>;
            var eat_hotal = data['eat_hotal'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(
                              location: location,
                              duration: duration,
                              description: description,
                              name: name,
                              imageList: imageList,
                              eat_hotal: eat_hotal)));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  child: Card(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: CachedNetworkImage(
                            imageUrl: data['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180.h,
                            filterQuality: FilterQuality.high,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                            ),
                            // Positioned(
                            //   top: 0,
                            //   right: 0,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Container(
                            //         decoration: const BoxDecoration(
                            //             borderRadius:
                            //                 BorderRadius.all(Radius.circular(50)),
                            //             color: Colors.black12),
                            //         child: IconButton(
                            //           icon:
                            //               Icon(Icons.favorite, color: Colors.white,size: 30.sp,),
                            //           onPressed: () async {},
                            //         )),
                            //   ),
                            // ),
                            Positioned(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15),
                                          topRight: Radius.circular(15)),
                                      color: Colors.black54),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      data['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: GoogleFonts.lato(fontSize: 18.sp),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.timelapse,
                                    size: 22.sp,
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Text(
                                    data['duration'].toString(), // Price value
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              RatingBar.builder(
                                itemSize: 20.w,
                                initialRating: rating.toDouble(),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.red,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              SizedBox(
                                height: 5.sp,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}