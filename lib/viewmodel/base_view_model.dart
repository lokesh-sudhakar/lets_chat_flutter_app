import 'package:chat_app/enums/view_state.dart';
import 'package:chat_app/locator.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier{

    DatabaseHelper dbHelper = locator<DatabaseHelper>();

    ViewState _state;

    ViewState get state => this._state;

    void setState(ViewState state) {
        this._state = state;
        notifyListeners();
    }
}