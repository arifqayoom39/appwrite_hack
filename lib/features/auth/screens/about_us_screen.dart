import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF0F172A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About PopStore',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Empowering Entrepreneurs Worldwide',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'At PopStore, we believe that everyone deserves the opportunity to build their dream online business. Founded in 2020, our mission is to democratize ecommerce by providing powerful, user-friendly tools that make it easy for anyone to create stunning online stores without the need for technical expertise.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Our Story',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PopStore was born from the frustration of our founders with the complexity and high costs associated with traditional ecommerce platforms. We saw an opportunity to create a solution that combines cutting-edge technology with intuitive design, making it possible for small businesses, entrepreneurs, and creators to launch professional online stores in minutes.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'What Sets Us Apart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildBulletPoint('AI-Powered Design: Our intelligent system creates beautiful, conversion-optimized stores automatically.'),
              _buildBulletPoint('Mobile-First Approach: Every store is optimized for all devices, ensuring your customers have a seamless experience.'),
              _buildBulletPoint('No Coding Required: Build professional stores with our drag-and-drop interface.'),
              _buildBulletPoint('Integrated Payments: Accept payments worldwide with our secure, built-in payment processing.'),
              _buildBulletPoint('24/7 Support: Our expert team is always here to help you succeed.'),
              const SizedBox(height: 32),
              const Text(
                'Our Vision',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We envision a world where anyone with a great idea can easily turn it into a thriving online business. By removing technical barriers and providing affordable, powerful tools, we\'re helping millions of entrepreneurs around the globe achieve their dreams.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Join Our Community',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'When you choose PopStore, you\'re not just getting a platform – you\'re joining a community of successful entrepreneurs, creators, and innovators. We\'re here to support you every step of the way, from your first store launch to scaling your business to new heights.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Your Journey Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
