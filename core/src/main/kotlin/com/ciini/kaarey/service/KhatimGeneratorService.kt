package com.ciini.kaarey.service

import com.ciini.kaarey.abjad.AbjadResult
import com.ciini.kaarey.abjad.AbjadTables
import com.ciini.kaarey.generator.BaseLayouts
import com.ciini.kaarey.generator.BorderMethodGenerator
import com.ciini.kaarey.generator.ConfigurationTechniqueGenerator
import com.ciini.kaarey.model.AbjadSystem
import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.KhatimResult
import com.ciini.kaarey.model.KhatimType
import com.ciini.kaarey.model.MagicSquare
import com.ciini.kaarey.spirit.CharacteristicsCalculator
import com.ciini.kaarey.spirit.SpiritNameExtractor

/**
 * Façade de génération d'un Khatim complet (carré + caractéristiques + esprits).
 */
object KhatimGeneratorService {

    fun computeAbjad(text: String, system: AbjadSystem): AbjadResult =
        AbjadTables.computeMysticalWeight(text, system)

    fun generate(
        type: KhatimType,
        method: ConstructionMethod,
        mysticalWeight: Int,
    ): Result<KhatimResult> = runCatching {
        require(mysticalWeight > 0) { "Le Poids Mystique doit être un entier positif." }

        if (method != ConstructionMethod.ADVANCED_CONFIGURATION && type.order % 2 == 0) {
            error(
                "Les méthodes de bordures (intérieur/extérieur) ne s'appliquent " +
                    "qu'aux dimensions impaires (3, 5, 7, 9). " +
                    "Choisissez la Configuration Avancée pour un ${type.frenchName}.",
            )
        }

        val square: MagicSquare = when (method) {
            ConstructionMethod.ADVANCED_CONFIGURATION ->
                ConfigurationTechniqueGenerator.generate(type.order, mysticalWeight)

            ConstructionMethod.FROM_INTERIOR ->
                BorderMethodGenerator.generateFromInterior(type.order, mysticalWeight)

            ConstructionMethod.FROM_EXTERIOR ->
                BorderMethodGenerator.generateFromExterior(type.order, mysticalWeight)
        }

        val houseLayout = when (method) {
            ConstructionMethod.ADVANCED_CONFIGURATION -> BaseLayouts.houseLayout(type.order)
            else -> {
                // Pour les bordures, les « maisons » suivent l'ordre des valeurs de base 1..n²
                val baseOffset = square.entry - 1
                Array(type.order) { r ->
                    IntArray(type.order) { c -> square.grid[r][c] - baseOffset }
                }
            }
        }

        val characteristics = CharacteristicsCalculator.compute(square, houseLayout)
        val balance = CharacteristicsCalculator.analyzeBalance(square)
        val spirits = SpiritNameExtractor.extractFromCharacteristics(characteristics)

        val paired = if (type == KhatimType.MOURABBA) {
            SpiritNameExtractor.extractMourabbaColumnCoupling(square)
        } else {
            emptyList()
        }

        KhatimResult(
            type = type,
            square = square,
            characteristics = characteristics,
            spirits = spirits,
            pairedSpirits = paired,
            isBalanced = balance.isBalanced,
            columnSums = balance.columnSums,
            rowSums = balance.rowSums,
            diagonalSums = balance.diagonalSums,
        )
    }

    /** PM par défaut = constante magique standard (carré 1..n²). */
    fun defaultPm(type: KhatimType): Int = type.order * (type.order * type.order + 1) / 2
}
