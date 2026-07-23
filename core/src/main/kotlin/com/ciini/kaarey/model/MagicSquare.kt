package com.ciini.kaarey.model

data class MagicSquare(
    val order: Int,
    val grid: Array<IntArray>,
    val entry: Int,
    val exit: Int,
    val remainder: Int,
    val mysticalWeight: Int,
    val method: ConstructionMethod,
) {
    init {
        require(grid.size == order) { "La grille doit être d'ordre $order" }
        require(grid.all { it.size == order }) { "Chaque ligne doit avoir $order cellules" }
    }

    fun cell(row: Int, col: Int): Int = grid[row][col]

    fun copyGrid(): Array<IntArray> = Array(order) { r -> grid[r].copyOf() }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is MagicSquare) return false
        return order == other.order &&
            mysticalWeight == other.mysticalWeight &&
            entry == other.entry &&
            exit == other.exit &&
            remainder == other.remainder &&
            method == other.method &&
            grid.contentDeepEquals(other.grid)
    }

    override fun hashCode(): Int {
        var result = order
        result = 31 * result + grid.contentDeepHashCode()
        result = 31 * result + entry
        result = 31 * result + exit
        result = 31 * result + remainder
        result = 31 * result + mysticalWeight
        result = 31 * result + method.hashCode()
        return result
    }
}

/**
 * Caractéristiques communes d'un Khatim (clés ésotériques).
 */
data class KhatimCharacteristics(
    val cle: Int,          // مفتاح — plus petit / première maison
    val verrou: Int,       // مغلاق — plus grand / dernière maison
    val mediane: Int,      // عدل — clé + verrou
    val wafq: Int,         // وفق — somme d'une colonne
    val aire: Int,         // مساحة — somme totale
    val force: Int,        // ضابط — wafq + aire
    val but: Int,          // غاية — 2 × force
) {
    fun asLabeledList(): List<Pair<String, Int>> = listOf(
        "Clé (مفتاح)" to cle,
        "Verrou (مغلاق)" to verrou,
        "Médiane (عدل)" to mediane,
        "WAFQ (وفق)" to wafq,
        "Aire / Masahat (مساحة)" to aire,
        "Force / Dhabit (ضابط)" to force,
        "But / Ghayat (غاية)" to but,
    )
}

data class SpiritName(
    val sourceLabel: String,
    val sourceValue: Int,
    val celestialArabic: String,
    val celestialLatin: String,
    val terrestrialArabic: String,
    val terrestrialLatin: String,
    val revolutionsAdded: Int,
)

data class PairedSpiritName(
    val label: String,
    val first: Int,
    val second: Int,
    val arabic: String,
    val latin: String,
    val kind: SpiritKind,
)

enum class SpiritKind { CELESTIAL, TERRESTRIAL }

data class KhatimResult(
    val type: KhatimType,
    val square: MagicSquare,
    val characteristics: KhatimCharacteristics,
    val spirits: List<SpiritName>,
    val pairedSpirits: List<PairedSpiritName> = emptyList(),
    val isBalanced: Boolean,
    val columnSums: List<Int>,
    val rowSums: List<Int>,
    val diagonalSums: List<Int>,
)
