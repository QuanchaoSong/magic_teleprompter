import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:magic_teleprompter/others/models/PromterModel.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/SqliteTool.dart';
import 'CreatePromterPage.dart';
import 'others/tools/HudTool.dart';
import 'others/models/PromterModel.dart';

class RealHomePage extends StatefulWidget {
  static GlobalKey<ScaffoldState> globalKey;

  @override
  State<StatefulWidget> createState() {
    return _RealHomePageState();
  }
}

class _RealHomePageState extends State<RealHomePage> {
  List arrOfData = [];
  int page = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1000), () {
      _getDataFromLocalDB();
    });
  }

  Future _getDataFromLocalDB() async {
    List rawArr = await SqliteTool().getPromterList(this.page);
    if (listLength(rawArr) == 0) {
      return;
    }

    List arr = rawArr.map((item) => PromterModel.fromJson(item)).toList();
    if (this.page == 0) {
      this.arrOfData.clear();
    }
    setState(() {
      this.arrOfData.addAll(arr);
    });
  }

  @override
  Widget build(BuildContext context) {
    HudTool.APP_CONTEXT = context;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: _buildWaterflowView(),
        ),

        // 发布按钮
        Positioned(
            bottom: 25,
            left: (MediaQuery.of(context).size.width - 70) / 2.0,
            child: _buildCreatePostButton())
      ],
    );
  }

  Widget _buildWaterflowView() {
    return Scrollbar(
        child: StaggeredGridView.countBuilder(
      padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
      crossAxisCount: 4,
      itemCount: listLength(this.arrOfData),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: _buildWaterflowItem(index),
          onTap: () {
            _tryToEnterDetailPage(index);
          },
        );
      },
      staggeredTileBuilder: (int index) {
        return StaggeredTile.fit(2);
      },
      mainAxisSpacing: 30.0,
      crossAxisSpacing: 24.0,
    ));
  }

  Widget _buildWaterflowItem(int index) {
    PromterModel m = this.arrOfData[index];
    return Container(
      decoration: BoxDecoration(
        color: randomColor(),
        borderRadius: BorderRadius.all(Radius.circular(13.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
            // color: randomColor(),
            child: Text(
              m.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Damascus",
                  fontSize: 26,
                  color: hexColor("111111")),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
            // color: randomColor(),
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Image.asset(
                    "assets/images/首页-删除按钮.png",
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                    print("delete");
                  },
                ),
                Expanded(child: SizedBox()),
                GestureDetector(
                  child: Image.asset(
                    "assets/images/首页-使用按钮.png",
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                    print("use");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(3, 3.0),
            spreadRadius: 0,
            color: Color(0xaa000000),
          ),
        ],
        gradient: new LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [hexColor("7BC1EA"), hexColor("8134B9")]),
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/发布按钮.png",
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            width: 70,
            height: 70,
            child: FlatButton(
              child: null,
              // color: hexColor("00E8EC"),
              // highlightColor: Colors.white70,
              // colorBrightness: Brightness.dark,
              splashColor: Colors.white70,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0)),
              onPressed: () {
                print("kkkkkkkkkkkllllllll");
                _tryToCreatePrompter();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _tryToEnterDetailPage(int index) async {
    PromterModel m = this.arrOfData[index];
    PromterModel theData = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => CreatePromterPage(data: m)));
    print("editedTheData: $theData");
    setState(() {
      m.title = theData.title;
      m.content = theData.content;
    });
  }

  Future _tryToCreatePrompter() async {
    PromterModel theData = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => CreatePromterPage()));
    print("theData: $theData");
    setState(() {
      this.arrOfData.insert(0, theData);
    });
  }
}