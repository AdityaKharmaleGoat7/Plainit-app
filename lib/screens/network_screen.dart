import 'package:flutter/material.dart';

class NetworkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A1A2E),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/chill.jpg'), // Correct path
                ),
                SizedBox(height: 20),
                Text(
                  "Chill Guys",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Flutter Developers, AI/ML Engineers & UI/UX Designers",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white.withOpacity(0.1),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.email, "adityakharmale7@gmail.com"),
                        SizedBox(height: 10),
                        _buildInfoRow(Icons.phone, "+91 9284262028"),
                        SizedBox(height: 10),
                        _buildInfoRow(Icons.location_on, "Pune, Maharashtra, India"),
                        SizedBox(height: 10),
                        _buildInfoRow(Icons.code, "Flutter, Dart, Python"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "We are a team of AI/ML enthusiasts, specializing in building complex models and providing optimized solutions. Our focus is on leveraging cutting-edge technologies to deliver efficient, scalable, and innovative solutions that solve real-world challenges.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add action for contact button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE94560),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    "Contact US",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}