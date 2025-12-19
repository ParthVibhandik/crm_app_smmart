import 'package:flutex_admin/common/components/card/glass_card.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';

class UniversalSearch extends StatelessWidget {
  const UniversalSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.space15),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: 5),
      borderRadius: 30,
      opacity: 0.15,
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: regularDefault.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search leads, tasks, customers...',
                hintStyle: regularDefault.copyWith(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
