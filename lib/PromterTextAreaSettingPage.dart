import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:fsuper/fsuper.dart';
import 'package:sqflite/utils/utils.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/NotificationCenter.dart';

class PromterTextAreaSettingPage extends StatefulWidget {
  PromterTextAreaSettingPage(this.txtSettings);
  final TextAreaSettings txtSettings;

  @override
  _PromterTextAreaSettingPageState createState() =>
      _PromterTextAreaSettingPageState(this.txtSettings);
}

class _PromterTextAreaSettingPageState
    extends State<PromterTextAreaSettingPage> {
  _PromterTextAreaSettingPageState(this.txtSettings);
  final TextAreaSettings txtSettings;

  final List _textColorStrings = [
    "FFFFFF",
    "EDC055",
    "27B3BF",
    "BF27AA",
    "E67366",
    "EDC055",
    "27B3BF",
    "BF27AA"
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _buildBody(),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SizedBox(width: 1)),
          GestureDetector(
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 30),
              padding: EdgeInsets.only(bottom: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: hexColor("ffffff", 0.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChooseTextColor(),
                    _buildTextFontSizeSlider(),
                    _buildChooseBackgroundColor(),
                    _buildBackgroundAlphaSlider(),
                    _buildTextScrollingSpeedSlider(),
                  ],
                ),
              ),
            ),
            onTap: () {
              print("aaaaaaaaaaa");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChooseTextColor() {
    List<Widget> widgets = [];
    FSuper title = FSuper(
      margin: EdgeInsets.only(right: 10),
      text: "文字颜色",
      style: TextStyle(
          color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
    );
    widgets.add(title);
    widgets.addAll(_createTextColorSelections());
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
      // color: randomColor(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> _createTextColorSelections() {
    List<Widget> result = [];
    for (int i = 0; i < listLength(_textColorStrings); i++) {
      String colorString = _textColorStrings[i];
      GestureDetector g = GestureDetector(
        child: Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            border: new Border.all(
                width: (colorString.toLowerCase() ==
                        this.txtSettings.textHexColorString.toLowerCase())
                    ? 2
                    : 0,
                color: hexColor(i == 0 ? "f00000" : "ffffff")),
            borderRadius: BorderRadius.all(Radius.circular(9)),
            color: hexColor(colorString),
          ),
        ),
        onTap: () {
          setState(() {
            this.txtSettings.textHexColorString = colorString;
          });
          NotificationCenter()
              .postNotification("textAreaSettingsChanged", this.txtSettings);
        },
      );
      result.add(g);
    }
    return result;
  }

  Widget _buildTextFontSizeSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "文字大小",
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.fontSize,
                min: 10,
                max: 100,
                label: this.txtSettings.fontSize.toInt().toString(),
                divisions: 90,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("kkdkdkdk: $v");
                  setState(() {
                    this.txtSettings.fontSize = v;
                  });
                  NotificationCenter().postNotification(
                      "textAreaSettingsChanged", this.txtSettings);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseBackgroundColor() {
    List<Widget> widgets = [];
    FSuper title = FSuper(
      margin: EdgeInsets.only(right: 10),
      text: "背景颜色",
      style: TextStyle(
          color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
    );
    widgets.add(title);
    widgets.addAll(_createBackgroundColorSelections());
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> _createBackgroundColorSelections() {
    List<Widget> result = [];
    for (int i = 0; i < listLength(_textColorStrings); i++) {
      String colorString = _textColorStrings[i];
      GestureDetector g = GestureDetector(
        child: Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            border: new Border.all(
                width: (colorString.toLowerCase() ==
                        this.txtSettings.backgroundHexColorString.toLowerCase())
                    ? 2
                    : 0,
                color: hexColor(i == 0 ? "f00000" : "ffffff")),
            borderRadius: BorderRadius.all(Radius.circular(9)),
            color: hexColor(colorString),
          ),
        ),
        onTap: () {
          setState(() {
            this.txtSettings.backgroundHexColorString = colorString;
          });
          NotificationCenter()
              .postNotification("textAreaSettingsChanged", this.txtSettings);
        },
      );
      result.add(g);
    }
    return result;
  }

  Widget _buildBackgroundAlphaSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "背景alpha",
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.backgroundAlpha,
                min: 0.01,
                max: 1.0,
                label:
                    '${(this.txtSettings.backgroundAlpha * 100.0).toInt().toString()}%',
                divisions: 100,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("uuuuuuu: $v");
                  setState(() {
                    this.txtSettings.backgroundAlpha = v;
                  });
                  NotificationCenter().postNotification(
                      "textAreaSettingsChanged", this.txtSettings);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextScrollingSpeedSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "滚动速度",
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.textScrollingSpeed,
                min: 10.0,
                max: (15.0 * 60),
                label: _generateInteligientScrollingDurationText(
                    this.txtSettings.textScrollingSpeed.toInt()),
                divisions: 15 * 60 - 10,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("nnnnnn: $v");
                  setState(() {
                    this.txtSettings.textScrollingSpeed = v;
                  });
                  NotificationCenter().postNotification(
                      "textAreaSettingsScrollingDurationChanged",
                      this.txtSettings);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateInteligientScrollingDurationText(int seconds) {
    if (seconds < 60) {
      return '${seconds}秒滚完';
    } else {
      int minutes = (seconds / 60.0).ceil().toInt();
      return '${minutes}分钟内滚完';
    }
  }
}