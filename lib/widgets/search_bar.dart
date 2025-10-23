import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Kitap ara...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onPressed: () => _clearSearch(context),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: TextStyle(color: theme.colorScheme.onSurface),
        onChanged: (value) {
          if (value.isEmpty) {
            Provider.of<BookProvider>(context, listen: false).resetToPopular();
          }
          setState(() {});
        },
        onSubmitted: (value) => _search(context),
      ),
    );
  }

  void _search(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      Provider.of<BookProvider>(
        context,
        listen: false,
      ).searchBooks(_controller.text, reset: true);
    }
  }

  void _clearSearch(BuildContext context) {
    _controller.clear();
    Provider.of<BookProvider>(context, listen: false).resetToPopular();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
