import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectProvider>().subjects;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subjects & Course Tags',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: subjects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _courseColor(index).withValues(alpha: .15),
              child: Icon(Icons.book_rounded, color: _courseColor(index)),
            ),
            title: Text(
              subjects[index].name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showCourseDialog(subject: subjects[index]);
                }
                if (value == 'delete') _confirmDeleteCourse(subjects[index]);
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

  Future<void> _confirmDeleteCourse(Subject subject) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete subject?'),
        content: Text(
          '“${subject.name}” will be removed. Existing tasks will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A65),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      final provider = context.read<SubjectProvider>();
      final success = await provider.deleteSubject(subject.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(provider.errorMessage ?? 'Could not delete subject.')));
      }
    }
  }

  Future<void> _showCourseDialog({Subject? subject}) async {
    final controller = TextEditingController(
      text: subject?.name ?? '',
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject == null ? 'Add subject' : 'Edit subject'),
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
    final provider = context.read<SubjectProvider>();
    final success = subject == null
        ? await provider.addSubject(
            name: value,
            colorValue: _courseColor(provider.subjects.length).toARGB32())
        : await provider.updateSubject(subject.copyWith(name: value));
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.errorMessage ?? 'Could not save subject.')));
    }
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
    return Material(
      color: colors.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
