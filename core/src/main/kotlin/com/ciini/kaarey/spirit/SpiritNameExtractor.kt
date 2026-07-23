package com.ciini.kaarey.spirit

import com.ciini.kaarey.abjad.AbjadTables
import com.ciini.kaarey.model.AbjadSystem
import com.ciini.kaarey.model.KhatimCharacteristics
import com.ciini.kaarey.model.MagicSquare
import com.ciini.kaarey.model.PairedSpiritName
import com.ciini.kaarey.model.SpiritKind
import com.ciini.kaarey.model.SpiritName

/**
 * Extraction des noms d'esprits-servants (célestes et terrestres)
 * selon le document des-caracteristiques-proprietes-usages-des-khawatim.
 *
 * - Céleste : valeur − 51 → lettres Abjad occidentales + suffixe ياءيل (YÂ-ÎL)
 * - Terrestre : valeur (+ 360×k si besoin) − 1019 → lettres + suffixe طيش (ṪÎSH)
 */
object SpiritNameExtractor {

    const val CELESTIAL_SUBTRACT = 51
    const val TERRESTRIAL_SUBTRACT = 1019
    const val REVOLUTION = 360

    const val CELESTIAL_SUFFIX_AR = "ياءيل"
    const val TERRESTRIAL_SUFFIX_AR = "طيش"
    const val CELESTIAL_SUFFIX_LATIN = "YÂ-ÎL"
    const val TERRESTRIAL_SUFFIX_LATIN = "ṪÎSH"

    fun extractFromCharacteristics(chars: KhatimCharacteristics): List<SpiritName> {
        return chars.asLabeledList().map { (label, value) ->
            extractForValue(label, value)
        }
    }

    fun extractForValue(label: String, value: Int): SpiritName {
        require(value > CELESTIAL_SUBTRACT) {
            "La valeur ($value) doit être > $CELESTIAL_SUBTRACT pour extraire l'esprit céleste."
        }

        val celestialRemainder = value - CELESTIAL_SUBTRACT
        val celestialLetters = AbjadTables.numberToLettersOrdered(celestialRemainder, AbjadSystem.OCCIDENTAL)

        var working = value
        var revolutions = 0
        while (working < TERRESTRIAL_SUBTRACT) {
            working += REVOLUTION
            revolutions++
        }
        val terrestrialRemainder = working - TERRESTRIAL_SUBTRACT
        val terrestrialLetters = AbjadTables.numberToLettersOrdered(terrestrialRemainder, AbjadSystem.OCCIDENTAL)

        return SpiritName(
            sourceLabel = label,
            sourceValue = value,
            celestialArabic = celestialLetters + CELESTIAL_SUFFIX_AR,
            celestialLatin = transliterate(celestialLetters) + CELESTIAL_SUFFIX_LATIN,
            terrestrialArabic = terrestrialLetters + TERRESTRIAL_SUFFIX_AR,
            terrestrialLatin = transliterate(terrestrialLetters) + TERRESTRIAL_SUFFIX_LATIN,
            revolutionsAdded = revolutions,
        )
    }

    /**
     * Cas particulier du Mourabba (4×4) : couplage par colonnes.
     * Méthode 1 du document — de la droite vers la gauche.
     *
     * Terrestres : couples (ligne3/ligne1) et (ligne4/ligne2) par colonne.
     * Célestes : couples (ligne2/ligne1) et (ligne4/ligne3) par colonne.
     */
    fun extractMourabbaColumnCoupling(square: MagicSquare): List<PairedSpiritName> {
        require(square.order == 4) { "Le couplage Mourabba s'applique au 4×4." }
        val g = square.grid
        val result = mutableListOf<PairedSpiritName>()

        // Colonnes de droite (c=3) vers gauche (c=0)
        for (c in 3 downTo 0) {
            // Terrestres : impairs (3/1) puis pairs (4/2) — indices 0-based : (2/0) et (3/1)
            result += pairSpirit(
                label = "Col.${c + 1} terrestres (3/1)",
                first = g[2][c],
                second = g[0][c],
                kind = SpiritKind.TERRESTRIAL,
            )
            result += pairSpirit(
                label = "Col.${c + 1} terrestres (4/2)",
                first = g[3][c],
                second = g[1][c],
                kind = SpiritKind.TERRESTRIAL,
            )
        }

        for (c in 3 downTo 0) {
            // Célestes : (2/1) et (4/3)
            result += pairSpirit(
                label = "Col.${c + 1} célestes (2/1)",
                first = g[1][c],
                second = g[0][c],
                kind = SpiritKind.CELESTIAL,
            )
            result += pairSpirit(
                label = "Col.${c + 1} célestes (4/3)",
                first = g[3][c],
                second = g[2][c],
                kind = SpiritKind.CELESTIAL,
            )
        }

        return result
    }

    /**
     * Méthode 2 Mourabba : couples contigus horizontaux (terrestres)
     * et verticaux (célestes), droite→gauche / haut→bas.
     */
    fun extractMourabbaContiguousCoupling(square: MagicSquare): List<PairedSpiritName> {
        require(square.order == 4)
        val g = square.grid
        val result = mutableListOf<PairedSpiritName>()

        // Terrestres : paires horizontales contiguës, droite→gauche, haut→bas
        for (r in 0 until 4) {
            result += pairSpirit(
                label = "Ligne${r + 1} (cases 4/3)",
                first = g[r][3],
                second = g[r][2],
                kind = SpiritKind.TERRESTRIAL,
            )
            result += pairSpirit(
                label = "Ligne${r + 1} (cases 2/1)",
                first = g[r][1],
                second = g[r][0],
                kind = SpiritKind.TERRESTRIAL,
            )
        }

        // Célestes : paires verticales contiguës, haut→bas, droite→gauche
        for (c in 3 downTo 0) {
            result += pairSpirit(
                label = "Col.${c + 1} (cases 1/2)",
                first = g[0][c],
                second = g[1][c],
                kind = SpiritKind.CELESTIAL,
            )
            result += pairSpirit(
                label = "Col.${c + 1} (cases 3/4)",
                first = g[2][c],
                second = g[3][c],
                kind = SpiritKind.CELESTIAL,
            )
        }

        return result
    }

    private fun pairSpirit(
        label: String,
        first: Int,
        second: Int,
        kind: SpiritKind,
    ): PairedSpiritName {
        // Le document illustre des noms formés par concaténation des lettres
        // des deux nombres (sans soustraction 51/1019 pour le couplage).
        val lettersFirst = AbjadTables.numberToLettersOrdered(first, AbjadSystem.OCCIDENTAL)
        val lettersSecond = AbjadTables.numberToLettersOrdered(second, AbjadSystem.OCCIDENTAL)
        val combined = lettersFirst + lettersSecond
        val (arabic, latin) = when (kind) {
            SpiritKind.CELESTIAL -> (combined + "ائيل") to (transliterate(combined) + "Â-ÎLOU")
            SpiritKind.TERRESTRIAL -> combined to (transliterate(combined) + "OUN")
        }
        return PairedSpiritName(
            label = label,
            first = first,
            second = second,
            arabic = arabic,
            latin = latin,
            kind = kind,
        )
    }

    private fun transliterate(arabic: String): String {
        val map = mapOf(
            'ا' to "A", 'ب' to "B", 'ج' to "J", 'د' to "D", 'ه' to "H",
            'و' to "W", 'ز' to "Z", 'ح' to "Ḥ", 'ط' to "Ṭ", 'ي' to "Y",
            'ك' to "K", 'ل' to "L", 'م' to "M", 'ن' to "N", 'س' to "S",
            'ع' to "‘", 'ف' to "F", 'ص' to "Ṣ", 'ق' to "Q", 'ر' to "R",
            'ش' to "SH", 'ت' to "T", 'ث' to "TH", 'خ' to "KH", 'ذ' to "DH",
            'ض' to "Ḍ", 'ظ' to "Ẓ", 'غ' to "GH",
        )
        return arabic.map { map[it] ?: it.toString() }.joinToString("")
    }
}

object CharacteristicsCalculator {

    /**
     * Calcule les 7 caractéristiques communes.
     * Clé = valeur de la première maison (layout house 1) = plus petit si reste 0 ;
     * Verrou = valeur de la dernière maison (house n²).
     */
    fun compute(square: MagicSquare, houseLayout: Array<IntArray>): KhatimCharacteristics {
        var cle = 0
        var verrou = 0
        for (r in houseLayout.indices) {
            for (c in houseLayout[r].indices) {
                when (houseLayout[r][c]) {
                    1 -> cle = square.grid[r][c]
                    square.order * square.order -> verrou = square.grid[r][c]
                }
            }
        }
        // Repli : min/max si layout non fourni correctement
        if (cle == 0) cle = square.entry
        if (verrou == 0) verrou = square.exit

        val wafq = square.grid[0].sum() // somme première ligne (= colonne si magique)
        val aire = square.grid.sumOf { it.sum() }
        val mediane = cle + verrou
        val force = wafq + aire
        val but = force * 2

        return KhatimCharacteristics(
            cle = cle,
            verrou = verrou,
            mediane = mediane,
            wafq = wafq,
            aire = aire,
            force = force,
            but = but,
        )
    }

    fun analyzeBalance(square: MagicSquare): BalanceReport {
        val n = square.order
        val rowSums = square.grid.map { it.sum() }
        val colSums = (0 until n).map { c -> (0 until n).sumOf { r -> square.grid[r][c] } }
        val diag1 = (0 until n).sumOf { square.grid[it][it] }
        val diag2 = (0 until n).sumOf { square.grid[it][n - 1 - it] }
        val target = square.mysticalWeight
        // Pour reste ≠ 0, seules lignes/colonnes égalisent le PM (pas toujours les diagonales)
        val rowsOk = rowSums.all { it == target }
        val colsOk = colSums.all { it == target }
        return BalanceReport(
            rowSums = rowSums,
            columnSums = colSums,
            diagonalSums = listOf(diag1, diag2),
            isBalanced = rowsOk && colsOk,
            targetSum = target,
        )
    }
}

data class BalanceReport(
    val rowSums: List<Int>,
    val columnSums: List<Int>,
    val diagonalSums: List<Int>,
    val isBalanced: Boolean,
    val targetSum: Int,
)
