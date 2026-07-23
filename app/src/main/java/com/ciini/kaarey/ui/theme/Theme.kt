package com.ciini.kaarey.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// Direction visuelle : encre profonde, or manusrit, parchemin doux — hors des biais IA courants.
private val Ink = Color(0xFF1A2332)
private val InkSoft = Color(0xFF2C3A4F)
private val Gold = Color(0xFFB0892E)
private val GoldDeep = Color(0xFF8C6A1F)
private val Parchment = Color(0xFFE8DFC9)
private val ParchmentDeep = Color(0xFFD4C7A8)
private val AccentTeal = Color(0xFF2F6F6A)
private val ErrorRed = Color(0xFF8B3A3A)

private val LightColors = lightColorScheme(
    primary = Ink,
    onPrimary = Parchment,
    primaryContainer = ParchmentDeep,
    onPrimaryContainer = Ink,
    secondary = GoldDeep,
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFF0E2B8),
    onSecondaryContainer = Ink,
    tertiary = AccentTeal,
    onTertiary = Color.White,
    background = Parchment,
    onBackground = Ink,
    surface = Color(0xFFF3ECD8),
    onSurface = Ink,
    surfaceVariant = ParchmentDeep,
    onSurfaceVariant = InkSoft,
    error = ErrorRed,
    onError = Color.White,
    outline = Color(0xFF8A7E62),
)

private val DarkColors = darkColorScheme(
    primary = Gold,
    onPrimary = Ink,
    primaryContainer = InkSoft,
    onPrimaryContainer = Parchment,
    secondary = Gold,
    onSecondary = Ink,
    background = Color(0xFF121820),
    onBackground = Parchment,
    surface = Color(0xFF1A2332),
    onSurface = Parchment,
    surfaceVariant = InkSoft,
    onSurfaceVariant = ParchmentDeep,
    error = Color(0xFFCF8A8A),
    onError = Ink,
)

private val AppTypography = Typography(
    displaySmall = TextStyle(
        fontFamily = FontFamily.Serif,
        fontWeight = FontWeight.Bold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = (-0.5).sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.Serif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Serif,
        fontWeight = FontWeight.SemiBold,
        fontSize = 20.sp,
        lineHeight = 28.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
    ),
)

@Composable
fun KhatimTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography = AppTypography,
        content = content,
    )
}
