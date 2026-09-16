import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/app_settings.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String localeCode;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.localeCode = 'en',
  });

  SettingsState copyWith({ThemeMode? themeMode, String? localeCode}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [themeMode, localeCode];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settings) : super(SettingsState()) {
    _load();
  }

  final AppSettings _settings;

  Future<void> _load() async {
    emit(SettingsState(
      themeMode: _settings.themeMode,
      localeCode: _settings.localeCode,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settings.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(String code) async {
    await _settings.setLocale(code);
    emit(state.copyWith(localeCode: code));
  }
}