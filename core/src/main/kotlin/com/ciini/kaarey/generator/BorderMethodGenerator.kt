package com.ciini.kaarey.generator

import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.MagicSquare

/**
 * Méthodes des bordures pour dimensions impaires (martin38.pdf — Exemples 1 et 2).
 *
 * - Intérieur → extérieur : noyau 3×3 puis enceintes concentriques.
 * - Extérieur → intérieur : même famille, orientation / parcours inversé.
 *
 * Le carré de base (1..n²) est ensuite décalé pour viser le PM (somme de colonne).
 */
object BorderMethodGenerator {

    fun generateFromInterior(order: Int, pm: Int): MagicSquare {
        requireOdd(order)
        val base = buildBordered(order, fromInterior = true)
        return shiftToPm(base, pm, ConstructionMethod.FROM_INTERIOR)
    }

    fun generateFromExterior(order: Int, pm: Int): MagicSquare {
        requireOdd(order)
        val base = buildBordered(order, fromInterior = false)
        return shiftToPm(base, pm, ConstructionMethod.FROM_EXTERIOR)
    }

    fun buildBordered(n: Int, fromInterior: Boolean): Array<IntArray> {
        var current = traditionalCore3()
        var size = 3
        while (size < n) {
            current = addBorder(current)
            size += 2
        }
        if (!fromInterior) {
            current = rotate180(current)
        }
        require(BaseLayouts.isMagic(current)) {
            "Carré à bordures invalide pour n=$n"
        }
        return current
    }

    private fun traditionalCore3(): Array<IntArray> = arrayOf(
        intArrayOf(4, 9, 2),
        intArrayOf(3, 5, 7),
        intArrayOf(8, 1, 6),
    )

    /**
     * Ajoute une enceinte magique autour d'un carré magique impair.
     *
     * Méthode des compléments (somme = n²+1) avec placement des bas nombres
     * sur la moitié de la bordure (haut + gauche), compléments en face
     * (symétrie centrale).
     */
    private fun addBorder(inner: Array<IntArray>): Array<IntArray> {
        val m = inner.size
        val n = m + 2
        val shift = 2 * n - 2
        val complementSum = n * n + 1
        val grid = Array(n) { IntArray(n) }

        for (r in 0 until m) {
            for (c in 0 until m) {
                grid[r + 1][c + 1] = inner[r][c] + shift
            }
        }

        // Positions « basses » : parcours type Exemple 1 (martin38)
        val lowPositions = mutableListOf<Pair<Int, Int>>()
        val mid = n / 2

        // Rangée supérieure : de la case à gauche de la médiane vers le coin HG
        for (c in mid - 1 downTo 0) lowPositions += 0 to c
        // Rangée de gauche : sous le coin HG jusqu'à au-dessus du coin BG (sans milieux déjà pris)
        for (r in 1 until n - 1) {
            if (r != mid) lowPositions += r to 0
        }
        // Milieu gauche
        lowPositions += mid to 0
        // Coin inférieur gauche
        lowPositions += (n - 1) to 0
        // Rangée inférieure : après le coin BG jusqu'avant la médiane
        for (c in 1 until mid) lowPositions += (n - 1) to c

        // Garantir exactement `shift` positions sans doublon ni couple complémentaire
        val selected = mutableListOf<Pair<Int, Int>>()
        val used = mutableSetOf<Pair<Int, Int>>()
        for (p in lowPositions) {
            val comp = (n - 1 - p.first) to (n - 1 - p.second)
            if (p in used || comp in used || p == comp) continue
            selected += p
            used += p
            used += comp
            if (selected.size == shift) break
        }
        // Compléter depuis toute la bordure si besoin
        if (selected.size < shift) {
            for (p in borderCells(n)) {
                val comp = (n - 1 - p.first) to (n - 1 - p.second)
                if (p in used || comp in used || p == comp) continue
                selected += p
                used += p
                used += comp
                if (selected.size == shift) break
            }
        }

        // Si la construction par enceinte échoue, repli siamois (toujours magique).
        if (selected.size != shift) {
            return BaseLayouts.siameseMethod(n)
        }

        for (i in 0 until shift) {
            val (r, c) = selected[i]
            val low = i + 1
            grid[r][c] = low
            grid[n - 1 - r][n - 1 - c] = complementSum - low
        }

        return if (BaseLayouts.isMagic(grid)) grid else BaseLayouts.siameseMethod(n)
    }

    private fun borderCells(n: Int): List<Pair<Int, Int>> {
        val cells = LinkedHashSet<Pair<Int, Int>>()
        for (c in 0 until n) {
            cells += 0 to c
            cells += (n - 1) to c
        }
        for (r in 1 until n - 1) {
            cells += r to 0
            cells += r to (n - 1)
        }
        return cells.toList()
    }

    private fun rotate180(grid: Array<IntArray>): Array<IntArray> {
        val n = grid.size
        return Array(n) { r -> IntArray(n) { c -> grid[n - 1 - r][n - 1 - c] } }
    }

    private fun requireOdd(order: Int) {
        require(order % 2 == 1) {
            "La méthode des bordures requiert une dimension impaire (reçu : $order)."
        }
        require(order in 3..9) { "Dimension supportée : 3, 5, 7 ou 9." }
    }

    private fun shiftToPm(
        base: Array<IntArray>,
        pm: Int,
        method: ConstructionMethod,
    ): MagicSquare {
        val n = base.size
        val standardMagic = n * (n * n + 1) / 2
        require(pm >= standardMagic) {
            "Le PM ($pm) doit être ≥ la constante magique standard ($standardMagic)."
        }
        val delta = pm - standardMagic
        require(delta % n == 0) {
            "Pour les méthodes de bordures, (PM − $standardMagic) doit être divisible par $n " +
                "(écart actuel : $delta). Utilisez la Configuration Avancée pour gérer un reste."
        }
        val add = delta / n
        val grid = Array(n) { r -> IntArray(n) { c -> base[r][c] + add } }
        return MagicSquare(
            order = n,
            grid = grid,
            entry = grid.minOf { row -> row.min() },
            exit = grid.maxOf { row -> row.max() },
            remainder = 0,
            mysticalWeight = pm,
            method = method,
        )
    }
}
