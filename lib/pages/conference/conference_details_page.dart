import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/main.dart';
import 'package:mydeca_flutter/models/conference.dart';
import 'package:mydeca_flutter/pages/conference/conference_media_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_overview_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_winner_page.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ConferenceDetailsPage extends StatefulWidget {
  @override
  _ConferenceDetailsPageState createState() => _ConferenceDetailsPageState();
}

class _ConferenceDetailsPageState extends State<ConferenceDetailsPage> {

  Conference conference = new Conference.plain();
  PageController _controller = new PageController();
  int currPage = 0;

  void renderConference(String route) {
    FirebaseDatabase.instance.reference().child("conferences").child(route.split("?id=")[1]).once().then((value) {
      setState(() {
        conference = new Conference.fromSnapshot(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (conference.conferenceID == "") renderConference(ModalRoute.of(context).settings.name);
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 0,
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      conference.conferenceID.split("-")[1],
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    background: Image.network(
                      conference.imageUrl,
                      fit: BoxFit.cover,
                    )),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: "OVERVIEW"),
                      Tab(text: "SCHEDULE"),
                      Tab(text: "WINNERS"),
                      Tab(text: "MEDIA"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: Container(
              child: new Expanded(
                child: new TabBarView(
                  children: [
                    new ConferenceOverviewPage(),
                    new ConferenceSchedulePage(),
                    new ConferenceWinnersPage(),
                    new ConferenceMediaPage(),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      padding: EdgeInsets.only(left: 4, top: 4, right: 4),
      child: Card(
        color: mainColor,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}