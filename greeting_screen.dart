
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gulfpgb/screens/calendar.dart';
import 'package:gulfpgb/screens/designlogo.dart';
import 'package:gulfpgb/screens/feed.dart';
import 'package:gulfpgb/screens/specs.dart';
import 'package:gulfpgb/screens/tabs_screen.dart';
import 'package:gulfpgb/screens/upcoming_events.dart';
import 'package:gulfpgb/widgets/navigation_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/languages.dart';
import '../helpers/current_user.dart';
import 'color_helper.dart';
import 'origin.dart';
const String _url = 'https://www.instagram.com/explore/tags/%D9%85%D8%A7%D8%B9%D8%B2/?hl=en';

void _launchURL() async {
  if (!await launch(_url)) throw 'Could not launch $_url';
}
const String phone = "+96594943380";
var whatsappUrl ="whatsapp://send?phone=$phone";

class GreetingScreen extends StatelessWidget{

  Map<String, String> langPack;


  final List<String> imageList = [
    'https://aopgr.online/storage/banner/bg1.jpeg',
    'https://aopgr.online/storage/banner/bg2.jpeg',
    'https://aopgr.online/storage/banner/bg3.jpeg',
  ];


  @override
  Widget build(BuildContext context) {
    const title = 'GULFPGR';

    langPack = Provider.of<Languages>(context).selected;
    return Stack(
        children: <Widget>
    [

    Positioned.fill(
    child:
    Container(
      constraints: BoxConstraints.expand(),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: ExactAssetImage('assets/images/background.jpeg'),
        ),
      ),
    ),
    ),
    Scaffold(
    extendBodyBehindAppBar: true,
      drawer: NavigationDrawerWidget(),

            appBar: AppBar(
              shape: AppBarBottomShape(),
              elevation: 0,
              backgroundColor: HexColor(),
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
    body: Container(
      constraints: BoxConstraints.expand(),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: ExactAssetImage('assets/images/background.jpeg'),
        ),
      ), child: SingleChildScrollView(
      child:
    Column(
      children: <Widget> [

    Container(
    margin: EdgeInsets.fromLTRB(0, 90, 0,0),
    //transform: Matrix4.translationValues(0.0, 50.0, 0.0),
    child:
    ClipRect(
    child:CarouselSlider(
      options: CarouselOptions(
        height: 100,
        aspectRatio: 16/9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      items: imageList.map((e) => GestureDetector(
    onTap: () {

      print("Image clicked!"); print(e);
      if(e == "https://aopgr.online/storage/banner/bg1.jpeg"){
        print("Banner 1 clicked");

        canLaunch(whatsappUrl) != null? launch(whatsappUrl):print("open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");


      }
      else if(e == "https://aopgr.online/storage/banner/bg3.jpeg"){
        print("Banner 3 clicked");
        launch(_url);
      }
    }, // Image tapped
    child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Image.network(e,
              width: MediaQuery.of(context).size.width,
              height: 104,
              fit: BoxFit.cover,)
          ],
        ) ,
      ))).toList(),
    ),
    ),
    ),
    Center(

    child: GridView.count(
        shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        GestureDetector(
          onTap: () { Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => TabsScreen(selectedTab: 0,),
            ),
                (route) => false,
          ); },
          child: Image.asset('assets/images/gridbuy.png' , fit: BoxFit.fitHeight,),
        ),
        GestureDetector(
          onTap: () {
            print("Container vet was tapped");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Vet()),
            );
            },
          child: Image.asset('assets/images/feed.png' , fit: BoxFit.fitHeight,),
        ),

        GestureDetector(
          onTap: () {
            print("Container Design Logo was tapped");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DesignLogo()),
            );
            },
          child: Image.asset('assets/images/designlogo.png' , fit: BoxFit.fitHeight,),
        ),
        GestureDetector(
          onTap: () {
            print("Container Upcoming Events was tapped");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpcomingEvents()),
          );
          },
          child: Image.asset('assets/images/features.png' , fit: BoxFit.fitHeight,),
        ),
        GestureDetector(
          onTap: () {
            print("Container Specs Logo was tapped");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Specs()),
            );
            },
          child: Image.asset('assets/images/specs.png' , fit: BoxFit.fitHeight,),
        ),
        GestureDetector(
          onTap: () {
            print("Container Origin was tapped");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Origin()),
            );
            },
          child: Image.asset('assets/images/origin.png' , fit: BoxFit.fitHeight,),
        ),
      ],
    ),
    ),
      ],
    ),
    ),

    ),
    ),
    ],


    );
  }

}

Widget buildImage(){
  return CachedNetworkImage(
    key: UniqueKey(),
    imageUrl: 'https://aopgr.online/storage/banner/bg.jpeg',
    imageBuilder: (context, imageProvider) => Container(
      height: 140,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(00.0)),
        color: Colors.white24,
        image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitWidth,
            colorFilter:
            ColorFilter.mode(Colors.transparent, BlendMode.colorBurn)),
      ),
    ),
    placeholder: (context, url) => CircularProgressIndicator(),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}