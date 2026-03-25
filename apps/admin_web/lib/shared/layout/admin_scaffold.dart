import 'package:flutter/material.dart';
import 'package:admin_web/shared/layout/admin_sidebar.dart';
import 'package:admin_web/shared/layout/admin_top_bar.dart';
import 'package:admin_web/shared/layout/admin_responsive_layout.dart';
import 'package:admin_web/shared/layout/admin_breadcrumb.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final List<BreadcrumbItem>? breadcrumbs;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveLayout(
      mobile: _MobileLayout(
        title: title,
        body: body,
        actions: actions,
        breadcrumbs: breadcrumbs,
      ),
      desktop: _DesktopLayout(
        title: title,
        body: body,
        actions: actions,
        breadcrumbs: breadcrumbs,
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final List<BreadcrumbItem>? breadcrumbs;

  const _DesktopLayout({
    required this.body,
    required this.title,
    this.actions,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(
                  title: title,
                  actions: actions,
                  breadcrumbs: breadcrumbs,
                ),
                if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    child: AdminBreadcrumb(items: breadcrumbs!),
                  ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final List<BreadcrumbItem>? breadcrumbs;

  const _MobileLayout({
    required this.body,
    required this.title,
    this.actions,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: AdminSidebar()),
      body: Column(
        children: [
          AdminTopBar(
            title: title,
            actions: actions,
            breadcrumbs: breadcrumbs,
            showMenuButton: true,
          ),
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surface,
              child: AdminBreadcrumb(items: breadcrumbs!),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
