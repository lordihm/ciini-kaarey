package com.ciini.kaarey.generator

/**
 * Carrés magiques de base (1..n²) utilisés comme « lay-out » (ordre des maisons).
 * Pour 3×3 et 4×4 : dispositions traditionnelles soufies documentées.
 * Pour les autres ordres : constructions classiques vérifiées.
 */
object BaseLayouts {

    /** Lay-out Moussalas classique (total = 15). */
    private val LAYOUT_3 = arrayOf(
        intArrayOf(4, 9, 2),
        intArrayOf(3, 5, 7),
        intArrayOf(8, 1, 6),
    )

    /**
     * Lay-out Mourabba traditionnel (ex. Latîf du document des caractéristiques).
     * Total colonnes/lignes = 34.
     */
    private val LAYOUT_4 = arrayOf(
        intArrayOf(8, 11, 14, 1),
        intArrayOf(13, 2, 7, 12),
        intArrayOf(3, 16, 9, 6),
        intArrayOf(10, 5, 4, 15),
    )

    fun houseLayout(order: Int): Array<IntArray> = when (order) {
        3 -> copyOf(LAYOUT_3)
        4 -> copyOf(LAYOUT_4)
        5, 7, 9 -> siameseMethod(order)
        6 -> stracheyMethod(6)
        8 -> doublyEvenMethod(8)
        else -> error("Ordre non supporté : $order (attendus 3..9)")
    }

    /** Méthode siamoise (De la Loubère) pour ordres impairs. */
    fun siameseMethod(n: Int): Array<IntArray> {
        require(n % 2 == 1) { "La méthode siamoise requiert un ordre impair" }
        val grid = Array(n) { IntArray(n) }
        var row = 0
        var col = n / 2
        for (num in 1..n * n) {
            grid[row][col] = num
            val nextRow = (row - 1 + n) % n
            val nextCol = (col + 1) % n
            if (grid[nextRow][nextCol] != 0) {
                row = (row + 1) % n
            } else {
                row = nextRow
                col = nextCol
            }
        }
        return grid
    }

    /** Méthode des pairs doubles (ordre multiple de 4). */
    fun doublyEvenMethod(n: Int): Array<IntArray> {
        require(n % 4 == 0) { "Ordre multiple de 4 requis" }
        val result = Array(n) { r -> IntArray(n) { c -> r * n + c + 1 } }
        for (r in 0 until n) {
            for (c in 0 until n) {
                if ((r % 4 == c % 4) || ((r + c) % 4 == 3)) {
                    result[r][c] = n * n + 1 - result[r][c]
                }
            }
        }
        return result
    }

    /**
     * Méthode de Strachey pour ordre simplement pair (n ≡ 2 mod 4), ex. 6×6.
     */
    fun stracheyMethod(n: Int): Array<IntArray> {
        require(n % 2 == 0 && n % 4 == 2) { "Ordre simplement pair requis (ex. 6)" }
        val m = n / 2
        val a = siameseMethod(m)
        val grid = Array(n) { IntArray(n) }

        fun fillQuadrant(rowOff: Int, colOff: Int, add: Int) {
            for (r in 0 until m) {
                for (c in 0 until m) {
                    grid[r + rowOff][c + colOff] = a[r][c] + add
                }
            }
        }

        // A B
        // C D  avec offsets 0, 2m², 3m², m²
        fillQuadrant(0, 0, 0)
        fillQuadrant(0, m, 2 * m * m)
        fillQuadrant(m, 0, 3 * m * m)
        fillQuadrant(m, m, m * m)

        val k = (m - 1) / 2
        // Échanges de colonnes gauches / droites selon Strachey
        for (r in 0 until m) {
            for (c in 0 until k) {
                swap(grid, r, c, r + m, c)
            }
            for (c in n - k + 1 until n) {
                swap(grid, r, c, r + m, c)
            }
        }
        // Colonne médiane du quadrant : échange centre
        swap(grid, k, 0, k + m, 0)
        swap(grid, k, k, k + m, k)

        return grid
    }

    private fun swap(grid: Array<IntArray>, r1: Int, c1: Int, r2: Int, c2: Int) {
        val tmp = grid[r1][c1]
        grid[r1][c1] = grid[r2][c2]
        grid[r2][c2] = tmp
    }

    fun isMagic(grid: Array<IntArray>): Boolean {
        val n = grid.size
        val expected = n * (n * n + 1) / 2
        for (r in 0 until n) {
            if (grid[r].sum() != expected) return false
        }
        for (c in 0 until n) {
            if ((0 until n).sumOf { grid[it][c] } != expected) return false
        }
        if ((0 until n).sumOf { grid[it][it] } != expected) return false
        if ((0 until n).sumOf { grid[it][n - 1 - it] } != expected) return false
        val flat = grid.flatMap { it.toList() }
        return flat.toSet() == (1..n * n).toSet()
    }

    private fun copyOf(src: Array<IntArray>): Array<IntArray> =
        Array(src.size) { r -> src[r].copyOf() }
}
