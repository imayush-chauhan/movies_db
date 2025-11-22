import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/cast.dart';
import '../../../../core/theme/app_theme.dart';

class CastList extends StatelessWidget {
  final List<Cast> cast;

  const CastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.cast,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              return _CastCard(cast: cast[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final Cast cast;

  const _CastCard({required this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cast.profilePath != null
                ? CachedNetworkImage(
              imageUrl: ApiConstants.getPosterUrl(
                cast.profilePath,
                size: ApiConstants.posterSizeSmall,
              ),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildPlaceholder(),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
                : _buildPlaceholder(),
          ),
          const SizedBox(height: 8),
          Text(
            cast.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (cast.character != null) ...[
            const SizedBox(height: 2),
            Text(
              cast.character!,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textHint,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.cardColor,
      child: const Icon(
        Icons.person,
        color: AppTheme.textHint,
        size: 32,
      ),
    );
  }
}