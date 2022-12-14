import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:video_compress_example/video_thumbnail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = 'video';

  Future<void> _compressVideo() async {
    var file;
    if (Platform.isMacOS) {
      final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
      file = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      final picker = ImagePicker();
      var pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      file = File(pickedFile!.path);
    }
    if (file == null) {
      return;
    }
    await VideoCompress.setLogLevel(3);
    var beginTime = DateTime.now();
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    var endTime = DateTime.now();
    var difference = endTime.difference(beginTime);

    print('压缩耗时(毫秒)');
    print(difference.inMilliseconds);
    if (info != null) {
      final fileSize = Platform.isMacOS
          ? (file as XFile).readAsBytes()
          : (file as File).readAsBytes();
      print("文件之前的大小");
      print((await fileSize).length);
      print('压缩后的大小');
      print(info.file?.readAsBytesSync().length);
      print('压缩后的路径');
      print(info.path);
      setState(() {
        _counter = info.path!;
      });
    }
  }

  // Subscription? _subscription;
  // @override
  // void initState() {
  //   super.initState();
  //   _subscription = VideoCompress.compressProgress$.subscribe((progress) {
  //     debugPrint('progress: $progress');
  //   });
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _subscription?.unsubscribe();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            InkWell(
              child: Icon(
                Icons.cancel,
                size: 55,
              ),
              onTap: () {
                VideoCompress.cancelCompression();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoThumbnail()),
                );
              },
              child: Text('Test thumbnail'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => _compressVideo(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
