@echo off
dart pub get
dart compile exe .\bin\flutter_installer.dart -o %userprofile%\Desktop\flutter_installer.exe

