// lib/core/widgets/skeleton_loading.dart
import 'package:flutter/material.dart';
import 'dart:math';

class SkeletonLoading extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    required this.height,
    this.width,
    this.borderRadius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SkeletonLoading(
            height: 40,
            width: 40,
            borderRadius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoading(
                  height: 18,
                  width: 180,
                  borderRadius: 4,
                ),
                SizedBox(height: 8),
                SkeletonLoading(
                  height: 14,
                  width: 240,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonAqiCard extends StatelessWidget {
  const SkeletonAqiCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoading(
                height: 18,
                width: 140,
                borderRadius: 4,
              ),
              SkeletonLoading(
                height: 18,
                width: 24,
                borderRadius: 4,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonLoading(
            height: 16,
            width: 100,
            borderRadius: 4,
          ),
          const SizedBox(height: 8),
          const SkeletonLoading(
            height: 16,
            width: 120,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}