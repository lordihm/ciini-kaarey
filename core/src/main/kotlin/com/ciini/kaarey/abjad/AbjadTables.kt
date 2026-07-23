package com.ciini.kaarey.abjad

import com.ciini.kaarey.model.AbjadSystem

/**
 * Tables Abjad (حساب الجمل) — systèmes occidental (maghrébin) et oriental (mashriqi).
 *
 * Différences principales sur : ص، ض، س، ش، ظ، غ
 */
object AbjadTables {

    private val sharedLow = mapOf(
        'ا' to 1, 'أ' to 1, 'إ' to 1, 'آ' to 1, 'ء' to 1,
        'ب' to 2,
        'ج' to 3,
        'د' to 4,
        'ه' to 5, 'ة' to 5,
        'و' to 6, 'ؤ' to 6,
        'ز' to 7,
        'ح' to 8,
        'ط' to 9,
        'ي' to 10, 'ى' to 10, 'ئ' to 10,
        'ك' to 20,
        'ل' to 30,
        'م' to 40,
        'ن' to 50,
        'ع' to 70,
        'ف' to 80,
        'ق' to 100,
        'ر' to 200,
        'ت' to 400,
        'ث' to 500,
        'خ' to 600,
        'ذ' to 700,
    )

    /** Comput oriental (mashriqi) — le plus répandu en Orient. */
    private val orientalExtra = mapOf(
        'س' to 60,
        'ص' to 90,
        'ش' to 300,
        'ض' to 800,
        'ظ' to 900,
        'غ' to 1000,
    )

    /** Comput occidental (maghrébin) — utilisé notamment pour les noms d'esprits. */
    private val occidentalExtra = mapOf(
        'ص' to 60,
        'ض' to 90,
        'س' to 300,
        'ظ' to 800,
        'غ' to 900,
        'ش' to 1000,
    )

    fun valueOf(char: Char, system: AbjadSystem): Int? {
        val normalized = normalize(char) ?: return null
        val base = sharedLow[normalized]
        if (base != null) return base
        return when (system) {
            AbjadSystem.ORIENTAL -> orientalExtra[normalized]
            AbjadSystem.OCCIDENTAL -> occidentalExtra[normalized]
        }
    }

    fun isArabicLetter(char: Char): Boolean = valueOf(char, AbjadSystem.ORIENTAL) != null

    /**
     * Calcule le Poids Mystique (PM) d'un texte arabe.
     * Ignore espaces, signes de ponctuation et diacritiques.
     */
    fun computeMysticalWeight(text: String, system: AbjadSystem): AbjadResult {
        if (text.isBlank()) {
            return AbjadResult(
                weight = 0,
                system = system,
                letterBreakdown = emptyList(),
                ignoredChars = emptyList(),
                error = "Le texte arabe ne peut pas être vide.",
            )
        }

        val breakdown = mutableListOf<LetterValue>()
        val ignored = mutableListOf<Char>()
        var sum = 0
        var hasArabic = false

        for (ch in text) {
            when {
                ch.isWhitespace() || isDiacritic(ch) || isPunctuation(ch) -> ignored += ch
                else -> {
                    val v = valueOf(ch, system)
                    if (v == null) {
                        ignored += ch
                    } else {
                        hasArabic = true
                        sum += v
                        breakdown += LetterValue(ch, v)
                    }
                }
            }
        }

        if (!hasArabic) {
            return AbjadResult(
                weight = 0,
                system = system,
                letterBreakdown = emptyList(),
                ignoredChars = ignored,
                error = "Aucune lettre arabe valide n'a été détectée.",
            )
        }

        return AbjadResult(
            weight = sum,
            system = system,
            letterBreakdown = breakdown,
            ignoredChars = ignored.filter { !it.isWhitespace() && !isDiacritic(it) },
            error = null,
        )
    }

    /**
     * Décompose un entier en lettres Abjad (unités → dizaines → centaines → milliers),
     * comme dans la tradition d'extraction des noms d'esprits.
     */
    fun numberToLetters(value: Int, system: AbjadSystem = AbjadSystem.OCCIDENTAL): String {
        require(value >= 0) { "La valeur doit être positive ou nulle" }
        if (value == 0) return ""

        val letters = lettersForSystem(system)
        val result = StringBuilder()
        var remaining = value

        // Unités
        val units = remaining % 10
        if (units > 0) {
            result.append(letterForValue(units, letters))
        }
        remaining /= 10

        // Dizaines
        val tens = remaining % 10
        if (tens > 0) {
            result.append(letterForValue(tens * 10, letters))
        }
        remaining /= 10

        // Centaines
        val hundreds = remaining % 10
        if (hundreds > 0) {
            result.append(letterForValue(hundreds * 100, letters))
        }
        remaining /= 10

        // Milliers (et au-delà, par tranches de 1000 via غ/ش selon le système)
        while (remaining > 0) {
            val thousandsDigit = remaining % 10
            if (thousandsDigit > 0) {
                repeat(thousandsDigit) {
                    result.append(letterForValue(1000, letters))
                }
            }
            remaining /= 10
            // Pour des valeurs > 9999, on empile les lettres de 1000
            // (approximation traditionnelle suffisante pour les PM usuels).
            if (remaining > 0) {
                // Chaque palier supérieur ajoute encore des 1000
                // via la boucle ; pour rester fidèle aux exemples documentés
                // (jusqu'à quelques milliers), on traite digit par digit.
            }
        }

        return result.toString()
    }

    /**
     * Variante robuste : décomposition gloutonne par valeurs Abjad décroissantes,
     * puis réordonnancement unités→dizaines→centaines→milliers.
     */
    fun numberToLettersOrdered(value: Int, system: AbjadSystem = AbjadSystem.OCCIDENTAL): String {
        if (value <= 0) return ""
        val letters = lettersForSystem(system).entries.sortedByDescending { it.value }
        val collected = mutableListOf<Pair<Char, Int>>()
        var remaining = value
        for ((letter, letterValue) in letters) {
            while (remaining >= letterValue) {
                collected += letter to letterValue
                remaining -= letterValue
            }
        }
        // Ordonner : 1-9, puis 10-90, puis 100-900, puis 1000+
        val ordered = collected.sortedWith(
            compareBy<Pair<Char, Int>> {
                when {
                    it.second < 10 -> 0
                    it.second < 100 -> 1
                    it.second < 1000 -> 2
                    else -> 3
                }
            }.thenBy { it.second },
        )
        return ordered.joinToString("") { it.first.toString() }
    }

    private fun lettersForSystem(system: AbjadSystem): Map<Char, Int> {
        val map = sharedLow.filterKeys { it in "ابجدهوزحطيكلمنعفقرتثخذ" }.toMutableMap()
        when (system) {
            AbjadSystem.ORIENTAL -> map.putAll(orientalExtra)
            AbjadSystem.OCCIDENTAL -> map.putAll(occidentalExtra)
        }
        return map
    }

    private fun letterForValue(value: Int, letters: Map<Char, Int>): Char =
        letters.entries.first { it.value == value }.key

    private fun normalize(char: Char): Char? = when (char) {
        'أ', 'إ', 'آ', 'ٱ' -> 'ا'
        'ؤ' -> 'و'
        'ئ' -> 'ي'
        'ة' -> 'ه'
        'ى' -> 'ي'
        else -> if (char in '\u0600'..'\u06FF') char else null
    }

    private fun isDiacritic(ch: Char): Boolean =
        ch in '\u064B'..'\u065F' || ch == '\u0670' || ch == '\u0640'

    private fun isPunctuation(ch: Char): Boolean =
        ch in "۔،؛؟!.:;,-_/\\\"'()[]{}«»…"
}

data class LetterValue(val letter: Char, val value: Int)

data class AbjadResult(
    val weight: Int,
    val system: AbjadSystem,
    val letterBreakdown: List<LetterValue>,
    val ignoredChars: List<Char>,
    val error: String?,
) {
    val isSuccess: Boolean get() = error == null && weight > 0
}
