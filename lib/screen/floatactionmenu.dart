import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FloatingActionMenuButton extends StatefulWidget {
  const FloatingActionMenuButton({Key? key}) : super(key: key);

  @override
  State<FloatingActionMenuButton> createState() =>
      _FloatingActionMenuButtonState();
}

class _FloatingActionMenuButtonState extends State<FloatingActionMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _toggleMenu() {
    if (isMenuOpen) {
      _overlayEntry?.remove();
      _animationController.reverse();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _animationController.forward();
    }
    isMenuOpen = !isMenuOpen;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - (size.width * 3.75),
        top: offset.dy - size.height * 1,
        width: size.width * 4,
        height: size.height * 3,
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildFloatingButton(FontAwesomeIcons.facebookF, Colors.blue,
                  "https://m.facebook.com/tobetoplatform?refid=13&__tn__=%2Cg"),
              _buildFloatingButton(
                  FontAwesomeIcons.linkedinIn,
                  Colors.blue[700]!,
                  "https://www.linkedin.com/company/tobeto/?originalSubdomain=tr"),
              _buildFloatingButton(FontAwesomeIcons.instagram, Colors.pink,
                  "https://www.instagram.com/tobeto_official/"),
              _buildFloatingButton(FontAwesomeIcons.whatsapp,
                  Colors.green[500]!, "https://whatsapp.com"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, Color color, String url) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
      onPressed: () async {
        Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return FloatingActionButton(
      backgroundColor: theme.brightness == Brightness.dark
          ? Theme.of(context).iconTheme.color
          : Theme.of(context).colorScheme.background,
      onPressed: _toggleMenu,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _animationController,
        color: theme.brightness == Brightness.dark
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).iconTheme.color,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
