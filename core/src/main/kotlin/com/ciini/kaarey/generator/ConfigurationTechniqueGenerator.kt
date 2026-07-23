package com.ciini.kaarey.generator

import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.KhatimType
import com.ciini.kaarey.model.MagicSquare

/**
 * Technique de configuration des Khatims (document technique-de-configuration-des-khatims).
 *
 * 1. Soustraire la constante C = n(n²-1)/2 du PM
 * 2. Diviser par n → entrée (quotient) et reste r
 * 3. Sortie = entrée + n² - 1 (+1 si r > 0)
 * 4. Placer entrée + (maison-1) ; ajouter +1 aux maisons ≥ startHouse(r)
 *    où startHouse(r) = n² - n·r + 1
 */
object ConfigurationTechniqueGenerator {

    data class ConfigParams(
        val entry: Int,
        val remainder: Int,
        val exit: Int,
        val startHouse: Int?,
        val subtracted: Int,
    )

    fun computeParams(order: Int, pm: Int): ConfigParams {
        val type = KhatimType.fromOrder(order)
        val c = type.subtractionConstant
        require(pm > c) {
            "Le PM ($pm) doit être supérieur à la constante de soustraction ($c) pour un ${type.frenchName}."
        }
        val subtracted = pm - c
        val entry = subtracted / order
        val remainder = subtracted % order
        require(entry >= 1) { "L'entrée calculée ($entry) est invalide. Augmentez le PM." }

        val startHouse = if (remainder == 0) null else order * order - order * remainder + 1
        val exit = entry + order * order - 1 + if (remainder > 0) 1 else 0

        return ConfigParams(
            entry = entry,
            remainder = remainder,
            exit = exit,
            startHouse = startHouse,
            subtracted = subtracted,
        )
    }

    fun generate(order: Int, pm: Int): MagicSquare {
        val params = computeParams(order, pm)
        val houses = BaseLayouts.houseLayout(order)
        val grid = Array(order) { IntArray(order) }
        val start = params.startHouse ?: Int.MAX_VALUE

        for (r in 0 until order) {
            for (c in 0 until order) {
                val house = houses[r][c]
                val increment = if (house >= start) 1 else 0
                grid[r][c] = params.entry + (house - 1) + increment
            }
        }

        return MagicSquare(
            order = order,
            grid = grid,
            entry = params.entry,
            exit = params.exit,
            remainder = params.remainder,
            mysticalWeight = pm,
            method = ConstructionMethod.ADVANCED_CONFIGURATION,
        )
    }
}
