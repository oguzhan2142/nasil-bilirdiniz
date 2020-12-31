import 'package:flutter/material.dart';
import 'package:kpss_tercih/post_widget.dart';
import 'package:kpss_tercih/profile_page/slidable_item.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Widget> createPostWidgetList() {
    List<Widget> postWidgets = List();

    postWidgets.add(Divider(color: Colors.amber, height: 50, thickness: 0.8));
    postWidgets.add(PostWidget());
    postWidgets.add(Divider(color: Colors.amber, height: 50, thickness: 0.8));
    postWidgets.add(PostWidget());
    postWidgets.add(Divider(color: Colors.amber, height: 50, thickness: 0.8));
    postWidgets.add(PostWidget());
    postWidgets.add(Divider(color: Colors.amber, height: 50, thickness: 0.8));
    postWidgets.add(PostWidget());
    postWidgets.add(Divider(color: Colors.amber, height: 50, thickness: 0.8));

    return postWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: constraints.copyWith(
                minHeight: constraints.maxHeight, maxHeight: double.infinity),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.36,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(150, 40),
                        bottomRight: Radius.elliptical(150, 40)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.menu),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(
                              Icons.menu,
                              color: Colors.transparent,
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 22,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(360),
                                  child: Image.asset(
                                    'res/user.png',
                                    width: 80,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Kullanici Adi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel dui odio. Cras f',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 15),
                                FlatButton(
                                  onPressed: () {},
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: Text(
                                    'Takip Et',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  color: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Column(children: createPostWidgetList())
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
