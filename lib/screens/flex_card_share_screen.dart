import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class FlexCardShareScreen extends StatelessWidget {
  final WorkoutSessionModel workout;
  final int totalXp;
  final PlayerProfileModel profile;

  const FlexCardShareScreen({
    super.key,
    required this.workout,
    required this.totalXp,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Share Your Progress'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Choose a Style',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _FlexCardOption(
              title: 'Classic',
              subtitle: 'Clean and simple',
              gradient: const [Color(0xFF7C4DFF), Color(0xFF536DFE)],
              icon: Icons.star,
              onTap: () => _shareCard(context, 'classic'),
            ),
            const SizedBox(height: 16),
            _FlexCardOption(
              title: 'Minimal',
              subtitle: 'Elegant monochrome',
              gradient: const [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
              icon: Icons.check_circle,
              onTap: () => _shareCard(context, 'minimal'),
            ),
            const SizedBox(height: 16),
            _FlexCardOption(
              title: 'Bold',
              subtitle: 'High contrast',
              gradient: const [Color(0xFF00E676), Color(0xFF00C853)],
              icon: Icons.bolt,
              onTap: () => _shareCard(context, 'bold'),
            ),
            const SizedBox(height: 16),
            _FlexCardOption(
              title: 'Gold',
              subtitle: 'Premium achievement',
              gradient: const [Color(0xFFFFD700), Color(0xFFFF8C00)],
              icon: Icons.emoji_events,
              onTap: () => _shareCard(context, 'gold'),
            ),
            const SizedBox(height: 32),
            // Preview
            Text(
              'Preview',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _FlexCardPreview(workout: workout, totalXp: totalXp, profile: profile),
          ],
        ),
      ),
    );
  }

  void _shareCard(BuildContext context, String style) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing $style card...')),
    );
    // In a real app, this would capture the card as an image and share it
  }
}

class _FlexCardOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _FlexCardOption({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.share, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _FlexCardPreview extends StatelessWidget {
  final WorkoutSessionModel workout;
  final int totalXp;
  final PlayerProfileModel profile;

  const _FlexCardPreview({
    required this.workout,
    required this.totalXp,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // App branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text('RPG WORKOUT', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 24),
          
          // XP Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('+$totalXp', style: GoogleFonts.inter(color: Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.bold)),
                Text('XP EARNED', style: GoogleFonts.inter(color: Colors.white70, letterSpacing: 2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: _formatDuration(workout.duration), label: 'Duration'),
              _StatItem(value: '${workout.sets.length}', label: 'Sets'),
              _StatItem(value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}t', label: 'Volume'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Character info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level ${profile.level} ${profile.characterTitle}',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
              Text('${profile.streakDays}', style: GoogleFonts.inter(color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date
          Text(
            _formatDate(workout.startTime),
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
