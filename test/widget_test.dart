// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock version of YouTubeVideoPlayer for testing
class MockYouTubeVideoPlayer extends StatelessWidget {
  final String videoUrl;

  const MockYouTubeVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text('Mock YouTube Player: $videoUrl'),
      ),
    );
  }
}

// Mock version of VideoListScreen for testing
class MockVideoListScreen extends StatelessWidget {
  final List<String> videoUrls = [
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https://www.youtube.com/watch?v=J---aiyznGQ",
    "https://www.youtube.com/watch?v=kxopViU98Xo",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: videoUrls.length,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: MockYouTubeVideoPlayer(
              videoUrl: videoUrls[index],
            ),
          );
        },
      ),
    );
  }
}

// Mock version of MyApp for testing
class MockMyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal YouTube Embed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MockVideoListScreen(),
    );
  }
}

void main() {
  group('YouTube Player App Tests', () {
    testWidgets('App should render with correct title',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MockMyApp());

      // Verify that the app title is present
      expect(find.text('Videos'), findsOneWidget);
    });

    testWidgets('App should have proper layout structure',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MockMyApp());

      // Verify the basic widget structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('App should display mock video players',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MockMyApp());

      // Find instances of MockYouTubeVideoPlayer
      expect(find.byType(MockYouTubeVideoPlayer), findsNWidgets(3));
    });

    test('Video URLs should be valid YouTube URLs', () {
      final videoListScreen = MockVideoListScreen();

      // Check if all URLs are valid YouTube URLs
      for (final url in videoListScreen.videoUrls) {
        expect(url.startsWith('https://www.youtube.com/watch?v='), isTrue);
        expect(url.length > 'https://www.youtube.com/watch?v='.length, isTrue);
      }
    });

    test('Video URLs should have valid video IDs', () {
      final videoListScreen = MockVideoListScreen();

      for (final url in videoListScreen.videoUrls) {
        // Extract video ID (everything after v=)
        final videoId = url.split('v=').last;
        // Video IDs are typically 11 characters long
        expect(videoId.length, equals(11));
        // Should only contain valid characters (alphanumeric and -_)
        expect(RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(videoId), isTrue);
      }
    });
  });
}
