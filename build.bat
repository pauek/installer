@echo off
dart pub get
dart compile exe .\bin\flutter_installer.dart -o flutter_installer.exe
