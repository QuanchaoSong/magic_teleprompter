import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'models/PromterModel.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/SqliteTool.dart';
import 'CreatePromterPage.dart';
import 'others/tools/HudTool.dart';
import 'package:easy_localization/easy_localization.dart';
import 'others/tools/AlertTool.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'UsePrompterPage.dart';

class RealHomePage extends StatefulWidget {
  static GlobalKey<ScaffoldState> globalKey;

  @override
  State<StatefulWidget> createState() {
    return _RealHomePageState();
  }
}

class _RealHomePageState extends State<RealHomePage> {
  EasyRefreshController _refreshController = EasyRefreshController();
  List arrOfData = [];
  int page = 0;
  final PromterModel _exampleData = PromterModel(
      0, "promter_example_title".tr(), "promter_example_content".tr(), 2);

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1000), () {
      _getDataFromLocalDB();
    });
  }

  Future _getDataFromLocalDB() async {
    List rawArr = await SqliteTool().getPromterList(this.page, pageSize: 1);
    print("rawArr: $rawArr");
    if (listLength(rawArr) == 0 && this.page > 0) {
      _refreshController.finishLoad(noMore: true);
      return;
    }

    List arr = rawArr.map((item) => PromterModel.fromJson(item)).toList();
    if (this.page == 0) {
      this.arrOfData.clear();
    }
    this.arrOfData.addAll(arr);
    this.arrOfData.remove(_exampleData);
    this.arrOfData.add(_exampleData);
    setState(() {});

    _refreshController.finishLoad();
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
        child: EasyRefresh(
      controller: _refreshController,
      taskIndependence: true,
      footer: MaterialFooter(),
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
      ),
      onLoad: () async {
        this.page++;
        _getDataFromLocalDB();
      },
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
              avoidNull(m.title),
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
                    _tryToDelete(index);
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
                    _tryToUse(index);
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
    PromterModel theEditedData = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) => CreatePromterPage(data: m)));
    print("theEditedData: $theEditedData");
    if (theEditedData == null) {
      return;
    }
    setState(() {
      m.title = theEditedData.title;
      m.content = theEditedData.content;
    });
  }

  Future _tryToCreatePrompter() async {
    PromterModel theData = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => CreatePromterPage()));
    print("theData: $theData");
    if (theData == null) {
      return;
    }
    setState(() {
      this.arrOfData.insert(0, theData);
    });
  }

  Future _tryToDelete(int index) async {
    PromterModel m = this.arrOfData[index];
    if (m.status == 2) {
      HudTool.showErrorWithStatus("示例文件不可删除");
      return;
    }

    bool isOkay = await AlertTool.showStandardAlert(context, "确定删除？");
    if (isOkay) {
      await SqliteTool().deletePrompter(m.the_id);
      setState(() {
        this.arrOfData.removeAt(index);
      });
    }
  }

  void _tryToUse(int index) {
    Navigator.push(context, _createUsePrompterPageRoute());
  }

  Route _createUsePrompterPageRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UsePrompterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }
}
