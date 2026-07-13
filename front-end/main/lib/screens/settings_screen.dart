import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.darkMode,
    required this.onDarkModeChanged,
    super.key,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          title: const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList.list(
            children: [
              const _SectionHeader('App Preferences'),
              const SizedBox(height: 9),
              _SettingsCard(
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  secondary: Icon(
                    darkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: colors.primary,
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Enable a dark theme for low light.'),
                  value: darkMode,
                  onChanged: onDarkModeChanged,
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader('Course Management'),
              const SizedBox(height: 9),
              _SettingsCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Icon(Icons.school_rounded, color: colors.primary),
                  title: const Text(
                    'Manage Subjects & Course Tags',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Add, edit, or delete subject codes and colors.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseManagementScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader('About'),
              const SizedBox(height: 9),
              _SettingsCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading:
                      Icon(Icons.info_outline_rounded, color: colors.primary),
                  title: const Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final List<String> _courses = ['CSC2074', 'MAT2032', 'General'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subjects & Course Tags',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _courses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _courseColor(index).withOpacity(.15),
              child: Icon(Icons.book_rounded, color: _courseColor(index)),
            ),
            title: Text(
              _courses[index],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showCourseDialog(index: index);
                if (value == 'delete') {
                  setState(() => _courses.removeAt(index));
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCourseDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add subject'),
      ),
    );
  }

  Color _courseColor(int index) {
    const colors = [Color(0xFF5B5CE2), Color(0xFFFFB648), Color(0xFF45B98C)];
    return colors[index % colors.length];
  }

  Future<void> _showCourseDialog({int? index}) async {
    final controller = TextEditingController(
      text: index == null ? '' : _courses[index],
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add subject' : 'Edit subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Subject code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(context, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    setState(() {
      if (index == null) {
        _courses.add(value);
      } else {
        _courses[index] = value;
      }
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: .7,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
