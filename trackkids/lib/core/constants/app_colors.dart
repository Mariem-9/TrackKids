import 'package:flutter/material.dart';

// This allows you to use: Theme.of(context).extension<ProjectColors>()!.primary
class ProjectColors extends ThemeExtension<ProjectColors> {
  final Color? primary;
  final Color? secondary;
  final Color? tertiary;
  final Color? background;
  final Color? accent;
  final Color? neutral;

  const ProjectColors({
    this.primary,
    this.secondary,
    this.tertiary,
    this.background,
    this.accent,
    this.neutral,
  });

  @override
  ProjectColors copyWith({Color? primary, Color? secondary, Color? tertiary, Color? background, Color? accent, Color? neutral}) {
    return ProjectColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      background: background ?? this.background,
      accent: accent ?? this.accent,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  ProjectColors lerp(ThemeExtension<ProjectColors>? other, double t) {
    if (other is! ProjectColors) return this;
    return ProjectColors(
      primary: Color.lerp(primary, other.primary, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      tertiary: Color.lerp(tertiary, other.tertiary, t),
      background: Color.lerp(background, other.background, t),
      accent: Color.lerp(accent, other.accent, t),
      neutral: Color.lerp(neutral, other.neutral, t),
    );
  }

  // --- PRESETS ---

  static const paletteOne = ProjectColors(
    primary: Color(0xFFf59e0b),
    secondary: Color(0xFFfbbf24),
    tertiary: Color(0xFF4b5563),
    background: Color(0xFFfffbeb),
    accent: Color(0xFFfef3c7),
    neutral: Color(0xFF1f2937),
  );

  static const paletteTwo = ProjectColors(
    primary: Color(0xFFa44b3f),
    secondary: Color(0xFFf09c78),
    tertiary: Color(0xFFcbdfbc),
    background: Color(0xFFf7f4d3),
    accent: Color(0xFFd5e09c),
    neutral: Color(0xFFa44b3f),
  );

  static const paletteThree = ProjectColors(
    primary: Color(0xFFf28930),
    secondary: Color(0xFFf6a685),
    tertiary: Color(0xFFe3af38),
    background: Color(0xFFf6d3bd),
    accent: Color(0xFFd0c2cf),
    neutral: Color(0xFFf28930),
  );
}