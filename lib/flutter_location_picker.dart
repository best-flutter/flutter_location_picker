import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './location.dart';

typedef DateChangedCallback(String province, String city, String town);

const double _kPickerHeight = 220.0;
const double _kPickerTitleHeight = 44.0;
const double _kPickerItemHeight = 40.0;

class LocationPicker {
  static void showPicker(
    BuildContext context, {
    bool showTitleActions: true,
    initialProvince: '上海市',
    initialCity: '上海市',
    initialTown: '长宁区',
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
  }) {
    Navigator.push(
        context,
        new _PickerRoute(
          showTitleActions: showTitleActions,
          initialProvince: initialProvince,
          initialCity: initialCity,
          initialTown: initialTown,
          onChanged: onChanged,
          onConfirm: onConfirm,
          theme: Theme.of(context, shadowThemeOnly: true),
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
        ));
  }
}

class _PickerRoute<T> extends PopupRoute<T> {
  _PickerRoute({
    this.showTitleActions,
    this.initialProvince,
    this.initialCity,
    this.initialTown,
    this.onChanged,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  final bool showTitleActions;
  final String initialProvince, initialCity, initialTown;
  final DateChangedCallback onChanged;
  final DateChangedCallback onConfirm;
  final ThemeData theme;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _PickerComponent(
        initialProvince: initialProvince,
        initialCity: initialCity,
        initialTown: initialTown,
        onChanged: onChanged,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = new Theme(data: theme, child: bottomSheet);
    }

    return bottomSheet;
  }
}

class _PickerComponent extends StatefulWidget {
  _PickerComponent({
    Key key,
    this.initialProvince,
    this.initialCity,
    this.initialTown,
    @required this.route,
    this.onChanged,
  });

  final String initialProvince, initialCity, initialTown;
  final DateChangedCallback onChanged;
  final _PickerRoute route;

  @override
  State<StatefulWidget> createState() =>
      _PickerState(this.initialProvince, this.initialCity, this.initialTown);
}

class _PickerState extends State<_PickerComponent> {
  String _currentProvince, _currentCity, _currentTown;
  var cities = [];
  var towns = [];
  var provinces = [];

  bool hasTown = true;

  AnimationController controller;
  Animation<double> animation;

  FixedExtentScrollController provinceScrollCtrl,
      cityScrollCtrl,
      townScrollCtrl;

  _PickerState(this._currentProvince, this._currentCity, this._currentTown) {
    provinces = Locations.provinces;
    hasTown = this._currentTown != null;

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          return new ClipRect(
            child: new CustomSingleChildLayout(
              delegate: new _BottomPickerLayout(widget.route.animation.value,
                  showTitleActions: widget.route.showTitleActions),
              child: new GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _init() {
    int pindex = 0;
    int cindex = 0;
    int tindex = 0;
    pindex = provinces.indexWhere((p) => p.indexOf(_currentProvince) >= 0);
    pindex = pindex >= 0 ? pindex : 0;
    String selectedProvince = provinces[pindex];
    if (selectedProvince != null) {
      _currentProvince = selectedProvince;

      cities = Locations.getCities(selectedProvince);
      if (!hasTown && cities.length == 1) {
        //不显示县城的时候 直辖市显示 areaList
        cities = cities[0]['areaList'].map((c) => {'name': c}).toList();
      }
      cindex = cities.indexWhere((c) => c['name'].indexOf(_currentCity) >= 0);
      cindex = cindex >= 0 ? cindex : 0;
      _currentCity = cities[cindex]['name'];

      if (hasTown) {
        towns = Locations.getTowns(_currentCity, cities);
        tindex = towns.indexWhere((t) => t.indexOf(_currentTown) >= 0) ?? 0;
        tindex = tindex >= 0 ? tindex : 0;
        _currentTown = towns[tindex];
      }
    }

    provinceScrollCtrl = new FixedExtentScrollController(initialItem: pindex);
    cityScrollCtrl = new FixedExtentScrollController(initialItem: cindex);
    townScrollCtrl = new FixedExtentScrollController(initialItem: tindex);
  }

  void _setProvince(int index) {
    String selectedProvince = provinces[index];
    if (_currentProvince != selectedProvince) {
      setState(() {
        _currentProvince = selectedProvince;

        cities = Locations.getCities(selectedProvince);
        if (!hasTown && cities.length == 1) {
          //不显示县城的时候 直辖市显示 areaList
          cities = cities[0]['areaList'].map((c) => {'name': c}).toList();
        }
        _currentCity = cities[0]['name'];
        cityScrollCtrl.jumpToItem(0);
        if (hasTown) {
          towns = Locations.getTowns(cities[0]['name'], cities);
          _currentTown = towns[0];
          townScrollCtrl.jumpToItem(0);
        }
      });

      _notifyLocationChanged();
    }
  }

  void _setCity(int index) {
    index = cities.length > index ? index : cities.length - 1;
    String selectedCity = cities[index]['name'];
    if (_currentCity != selectedCity) {
      if (hasTown) {
        setState(() {
          towns = Locations.getTowns(selectedCity, cities);
          townScrollCtrl.jumpToItem(0);
        });
      }
      _currentCity = selectedCity;
      _notifyLocationChanged();
    }
  }

  void _setTown(int index) {
    String selectedTown = towns[index];
    if (_currentTown != selectedTown) {
      _currentTown = selectedTown;
      _notifyLocationChanged();
    }
  }

  void _notifyLocationChanged() {
    if (widget.onChanged != null) {
      widget.onChanged(_currentProvince, _currentCity, _currentTown);
    }
  }

  double _pickerFontSize(String text) {
    double ratio = hasTown ? 0.0 : 2.0;
    if (text == null || text.length <= 6) {
      return 18.0;
    } else if (text.length < 9) {
      return 16.0 + ratio;
    } else if (text.length < 13) {
      return 12.0 + ratio;
    } else {
      return 10.0 + ratio;
    }
  }

  Widget _renderPickerView() {
    Widget itemView = _renderItemView();
    if (widget.route.showTitleActions) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(),
          itemView,
        ],
      );
    }
    return itemView;
  }

  Widget _renderItemView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(8.0),
            height: _kPickerHeight,
            decoration: BoxDecoration(color: Colors.white),
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              scrollController: provinceScrollCtrl,
              itemExtent: _kPickerItemHeight,
              onSelectedItemChanged: (int index) {
                _setProvince(index);
              },
              children: List.generate(Locations.provinces.length, (int index) {
                String text = Locations.provinces[index];
                return Container(
                  height: _kPickerItemHeight,
                  alignment: Alignment.center,
                  child: Text(
                    '$text',
                    style: TextStyle(
                        color: Color(0xFF000046),
                        fontSize: _pickerFontSize(text)),
                    textAlign: TextAlign.start,
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
              padding: EdgeInsets.all(8.0),
              height: _kPickerHeight,
              decoration: BoxDecoration(color: Colors.white),
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                scrollController: cityScrollCtrl,
                itemExtent: _kPickerItemHeight,
                onSelectedItemChanged: (int index) {
                  _setCity(index);
                },
                children: List.generate(cities.length, (int index) {
                  String text = cities[index]['name'];
                  return Container(
                    height: _kPickerItemHeight,
                    alignment: Alignment.center,
                    child: Text(
                      '$text',
                      style: TextStyle(
                          color: Color(0xFF000046),
                          fontSize: _pickerFontSize(text)),
                      textAlign: TextAlign.start,
                    ),
                  );
                }),
              )),
        ),
        hasTown
            ? Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.all(8.0),
                    height: _kPickerHeight,
                    decoration: BoxDecoration(color: Colors.white),
                    child: CupertinoPicker(
                      backgroundColor: Colors.white,
                      scrollController: townScrollCtrl,
                      itemExtent: _kPickerItemHeight,
                      onSelectedItemChanged: (int index) {
                        _setTown(index);
                      },
                      children: List.generate(towns.length, (int index) {
                        String text = towns[index];
                        return Container(
                          height: _kPickerItemHeight,
                          alignment: Alignment.center,
                          child: Text(
                            "${text}",
                            style: TextStyle(
                                color: Color(0xFF000046),
                                fontSize: _pickerFontSize(text)),
                            textAlign: TextAlign.start,
                          ),
                        );
                      }),
                    )),
              )
            : Center()
      ],
    );
  }

  // Title View
  Widget _renderTitleActionsView() {
    return Container(
      height: _kPickerTitleHeight,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _kPickerTitleHeight,
            child: FlatButton(
              child: Text(
                '取消',
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            height: _kPickerTitleHeight,
            child: FlatButton(
              child: Text(
                '确定',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () {
                if (widget.route.onConfirm != null) {
                  widget.route
                      .onConfirm(_currentProvince, _currentCity, _currentTown);
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {this.itemCount, this.showTitleActions});

  final double progress;
  final int itemCount;
  final bool showTitleActions;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = _kPickerHeight;
    if (showTitleActions) {
      maxHeight += _kPickerTitleHeight;
    }

    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
