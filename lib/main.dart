import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Entry point for the Flutter application.
void main() {
  runApp(MyApp());
}

/// MyApp is the root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal YouTube Embed',
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PasswordScreen(),
    );
  }
}

/// PasswordScreen displays a password input field and checks the password.
class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isError = false;
  static const String correctPassword = '1234';

  void _checkPassword() {
    if (_passwordController.text == correctPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VideoListScreen()),
      );
    } else {
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'Password Protected',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  errorText: _isError ? 'Incorrect password' : null,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                onSubmitted: (_) => _checkPassword(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPassword,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Enter'),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// VideoListScreen displays a scrollable list of YouTube videos.
class VideoListScreen extends StatelessWidget {
  // List of YouTube video URLs.
  final List<String> videoUrls = [
    "https://www.youtube.com/watch?v=0NSq1-Ne26Y&pp=ygUPdGFqIG1haGFsIGRyb25l", // Rick Astley - Never Gonna Give You Up
    "https://www.youtube.com/watch?v=sBYnOJSh_JU&pp=ygUONyB3b25kZXIgZHJvbmU%3D", // Sample video URL (e.g., a funny clip)
    "https://www.youtube.com/watch?v=BFS9n4B_2xA&pp=ygUWOCB3b25kZXJzIG9mIHRoZSB3b3JsZA%3D%3D", // Another sample video
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define if we're on a mobile device based on width
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            // Mobile Layout - Stacked
            return ListView.builder(
              itemCount: videoUrls.length,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        YouTubeVideoPlayer(
                          videoUrl: videoUrls[index],
                          width:
                              constraints.maxWidth - 32, // Account for padding
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Video ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            // Desktop Layout - Grid
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1200), // Maximum width for content
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: videoUrls.map((url) {
                      // Calculate the width for each video tile
                      double availableWidth = constraints.maxWidth > 1200 ? 1200 : constraints.maxWidth;
                      double tileWidth = (availableWidth - 48) / 2; // 48 accounts for padding and spacing
                      
                      // Ensure minimum and maximum width
                      tileWidth = tileWidth.clamp(300.0, 580.0);
                      
                      return SizedBox(
                        width: tileWidth,
                        child: Card(
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              YouTubeVideoPlayer(
                                videoUrl: url,
                                width: tileWidth,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Video ${videoUrls.indexOf(url) + 1}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

/// A widget that embeds a YouTube video using the youtube_player_iframe package.
class YouTubeVideoPlayer extends StatefulWidget {
  /// The complete YouTube video URL.
  final String videoUrl;

  /// The width of the video player.
  final double width;

  /// Constructor for the video widget.
  const YouTubeVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.width,
  }) : super(key: key);

  @override
  _YouTubeVideoPlayerState createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  // Controller that manages the YouTube player.
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Extract the YouTube video ID from the provided URL.
    // If extraction fails, throw an error for now.
    final String? videoId =
        YoutubePlayerController.convertUrlToId(widget.videoUrl);
    if (videoId == null) {
      throw 'Could not extract video ID from ${widget.videoUrl}';
    }

    // Initialize the YouTube player controller.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate height based on 16:9 aspect ratio
    final height = widget.width * 9 / 16;

    return SizedBox(
      width: widget.width,
      height: height,
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources.
    _controller.close();
    super.dispose();
  }
}
