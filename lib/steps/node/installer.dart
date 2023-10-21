import 'package:installer/steps/add_binary.dart';
import 'package:installer/steps/decompress.dart';
import 'package:installer/steps/download_file.dart';
import 'package:installer/steps/if.dart';
import 'package:installer/steps/node/is_node_installed.dart';
import 'package:installer/steps/node/node_get_download_url.dart';
import 'package:installer/steps/not.dart';
import 'package:installer/steps/rename.dart';
import 'package:installer/steps/step.dart';

Step iNode() {
  return Chain("NodeJS", [
    If(
      Not(IsNodeInstalled()),
      then: Chain.noPrefix([
        NodeGetDownloadURL(),
        DownloadFile(),
        Decompress(into: "node"),
        Rename(to: "node"),
        AddToEnv(dir: "node", items: [
          Binary("node", win: r"node\node.exe"),
          Binary("npm", win: r"node\npm.cmd"),
        ]),
      ]),
    )
  ]);
}
