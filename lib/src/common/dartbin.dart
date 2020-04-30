import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/src/dartbin_cmd.dart';
import 'package:pub_semver/pub_semver.dart';

String _dartExecutable;

///
/// Get dart vm either from executable or using the which command
///
String get dartExecutable => _dartExecutable ??= Platform.resolvedExecutable;

String get dartSdkBinDirPath => dirname(dartExecutable);

String get dartSdkDirPath => dirname(dartSdkBinDirPath);

Version _dartVersion;

/// Current dart platform version
Version get dartVersion =>
    _dartVersion ??= parsePlatformVersion(Platform.version);

String _dartChannel;

/// Current dart platform channel
String get dartChannel =>
    _dartChannel ??= parsePlatformChannel(Platform.version);

/// Stable channel.
String dartChannelStable = 'stable';

/// Beta channel.
String dartChannelBeta = 'beta';

/// Dev channel.
String dartChannelDev = 'dev';
