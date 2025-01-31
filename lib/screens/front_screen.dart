import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth
import 'dart:async'; // For Timer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: FrontScreen(),
    routes: {
      '/profile': (context) => ProfileScreen(userProfile: {}),
    },
  ));
}

class FrontScreen extends StatefulWidget {
  @override
  _FrontScreenState createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  // List of all features
  final List<Map<String, dynamic>> _allFeatures = [
    {
      "icon": Icons.calendar_today,
      "title": "Smart Calendar",
      "color": Color(0xFF64FFDA), // Soft Teal
      "route": '/calendar',
    },
    {
      "icon": Icons.auto_awesome,
      "title": "Insights",
      "color": Color(0xFFB388FF), // Soft Purple
      "route": '/insights',
    },
    {
      "icon": Icons.translate,
      "title": "Translator",
      "color": Color(0xFFFF8A80), // Soft Coral
      "route": '/translator',
    },
    {
      "icon": Icons.mic,
      "title": "Voice Assistant",
      "color": Color(0xFFFFD180), // Soft Amber
      "route": '/audio',
    },
    {
      "icon": Icons.meeting_room,
      "title": "Set a Meeting",
      "color": Color(0xFF4CAF50), // Green
      "route": '/schedule-meeting',
    },
    {
      "icon": Icons.auto_awesome,
      "title": "Speech",
      "color": Color(0xFF64FFDA), // Soft Teal
      "route": '/ai-speech',
    },
  ];

  // List to hold filtered features
  List<Map<String, dynamic>> _filteredFeatures = [];

  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  // User profile data
  Map<String, String> _userProfile = {
    "name": "John Doe",
    "email": "",
    "bio": "Flutter enthusiast.",
  };

  // List of rotating messages
  final List<String> _rotatingMessages = [
    "Convert your voice to text",
    "Get a summary of any topic",
    "Schedule meetings effortlessly",
    "Translate languages in real-time",
    "Boost productivity with insights",
  ];

  // Index for the current rotating message
  int _currentMessageIndex = 0;

  // Timer for rotating messages
  late Timer _messageTimer;

  // SharedPreferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _filteredFeatures = List.from(_allFeatures);
    _searchController.addListener(_filterFeatures);
    _startMessageTimer();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  // Load user profile from SharedPreferences
  Future<void> _loadUserProfile() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userProfile["name"] = _prefs.getString("name") ?? "John Doe";
      _userProfile["bio"] = _prefs.getString("bio") ?? "Flutter enthusiast.";
      _userProfile["email"] = FirebaseAuth.instance.currentUser?.email ?? "";
    });
  }

  // Save user profile to SharedPreferences
  Future<void> _saveUserProfile(Map<String, String> profile) async {
    await _prefs.setString("name", profile["name"]!);
    await _prefs.setString("bio", profile["bio"]!);
  }

  // Function to filter features based on search query
  void _filterFeatures() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFeatures = _allFeatures
          .where((feature) => feature["title"].toLowerCase().contains(query))
          .toList();
    });
  }

  // Function to start the rotating message timer
  void _startMessageTimer() {
    _messageTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _rotatingMessages.length;
      });
    });
  }

  // Function to navigate to the profile screen
  void _navigateToProfileScreen() async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userProfile: _userProfile,
        ),
      ),
    );

    if (updatedProfile != null) {
      await _saveUserProfile(updatedProfile);
      setState(() {
        _userProfile = updatedProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], // Dark gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.02),
                          // Container for Hi User, Profile Icon, and Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1), // Background color for the division
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            padding: EdgeInsets.all(16), // Padding inside the container
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hi User and Profile Icon in a Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Hi ${_userProfile["name"]}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    _buildProfileIcon(), // Profile icon
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Search Bar
                                _buildSearchBar(),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Rotating messages
                          _buildRotatingMessages(),
                          SizedBox(height: size.height * 0.02),
                          Expanded(child: _buildFeatureGrid(context)),
                        ],
                      ),
                    ),
                  ),
                  // Footer with 4 icons and thin lines
                  _buildBottomFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      height: 40, // Reduced height to make it thinner
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search features...",
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjusted padding
        ),
      ),
    );
  }

  // Rotating Messages Widget
  Widget _buildRotatingMessages() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF64FFDA).withOpacity(0.1), Color(0xFFB388FF).withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Text(
            _rotatingMessages[_currentMessageIndex],
            key: ValueKey<int>(_currentMessageIndex),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Profile Icon Widget
  Widget _buildProfileIcon() {
    return GestureDetector(
      onTap: _navigateToProfileScreen,
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Icon(Icons.person, color: Colors.white70),
      ),
    );
  }

  // Feature Grid Widget
  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, // Increase the number of columns to 3
      childAspectRatio: 0.8, // Adjust the aspect ratio to make icons smaller
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: EdgeInsets.only(bottom: 16),
      children: _filteredFeatures
          .map((feature) => _buildFeatureButton(
                context,
                icon: feature["icon"],
                title: feature["title"],
                color: feature["color"],
                route: feature["route"],
              ))
          .toList(),
    );
  }

  // Feature Button Widget
  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular icon container
          Container(
            padding: EdgeInsets.all(16), // Increased padding to make the icon larger
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, size: 30, color: color), // Increased icon size
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Footer with 4 icons and thin lines
  Widget _buildBottomFooter() {
    return Container(
      height: 60, // Height of the footer
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Background color for the footer
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.3), // Thin line at the top of the footer
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Home Icon
          Expanded(
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ),
          // Thin vertical line
          Container(
            width: 1.0,
            height: 30,
            color: Colors.white.withOpacity(0.3),
          ),
          // Network Icon
          Expanded(
            child: IconButton(
              icon: Icon(Icons.group, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/network');
              },
            ),
          ),
          // Thin vertical line
          Container(
            width: 1.0,
            height: 30,
            color: Colors.white.withOpacity(0.3),
          ),
          // Calendar Icon
          Expanded(
            child: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/calendar');
              },
            ),
          ),
          // Thin vertical line
          Container(
            width: 1.0,
            height: 30,
            color: Colors.white.withOpacity(0.3),
          ),
          // Settings Icon
          Expanded(
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white70),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
    );
  }

  // Exit Dialog
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Color(0xFF64FFDA), width: 1.5),
        ),
        title: Text(
          'Exit App?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Exit',
              style: TextStyle(color: Color(0xFF64FFDA)),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  final Map<String, String> userProfile;

  const ProfileScreen({required this.userProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile["name"]);
    _emailController = TextEditingController(text: widget.userProfile["email"]);
    _bioController = TextEditingController(text: widget.userProfile["bio"]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final updatedProfile = {
                "name": _nameController.text,
                "email": _emailController.text, // Email remains unchanged
                "bio": _bioController.text,
              };
              Navigator.pop(context, updatedProfile);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: "Bio"),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}