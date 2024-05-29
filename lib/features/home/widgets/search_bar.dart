import 'package:flutter/material.dart';

class UserSearchBar extends StatelessWidget {
  const UserSearchBar({super.key, required this.onSearch, required this.searchController});

  final TextEditingController searchController;
  final void Function(String value) onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: searchController,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Search chats...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.only(
            left: 10,
            bottom: 10,
          ),
        ),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.search,
        autofocus: true,
        onSubmitted: onSearch,
      ),
    );
  }
}
