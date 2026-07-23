package com.ciini.kaarey

import com.ciini.kaarey.abjad.AbjadTables
import com.ciini.kaarey.generator.BaseLayouts
import com.ciini.kaarey.generator.ConfigurationTechniqueGenerator
import com.ciini.kaarey.model.AbjadSystem
import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.KhatimType
import com.ciini.kaarey.service.KhatimGeneratorService
import com.ciini.kaarey.spirit.SpiritNameExtractor
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ConfigurationTechniqueTest {

    @Test
    fun moussalas_reste0_exemple1947() {
        val square = ConfigurationTechniqueGenerator.generate(3, 1947)
        assertEquals(645, square.entry)
        assertEquals(0, square.remainder)
        assertEquals(653, square.exit)
        // Disposition documentée :
        // 648 653 646
        // 647 649 651
        // 652 645 650
        assertEquals(648, square.grid[0][0])
        assertEquals(653, square.grid[0][1])
        assertEquals(646, square.grid[0][2])
        assertEquals(647, square.grid[1][0])
        assertEquals(649, square.grid[1][1])
        assertEquals(651, square.grid[1][2])
        assertEquals(652, square.grid[2][0])
        assertEquals(645, square.grid[2][1])
        assertEquals(650, square.grid[2][2])
        assertTrue(square.grid.all { row -> row.sum() == 1947 })
    }

    @Test
    fun moussalas_reste2_exemple635() {
        // Document caractéristiques : 635 → entrée 207 reste 2
        val square = ConfigurationTechniqueGenerator.generate(3, 635)
        assertEquals(207, square.entry)
        assertEquals(2, square.remainder)
        assertEquals(
            listOf(listOf(211, 216, 208), listOf(209, 212, 214), listOf(215, 207, 213)),
            square.grid.map { it.toList() },
        )
        assertTrue(square.grid.all { it.sum() == 635 })
    }

    @Test
    fun mourabba_latif_129() {
        val square = ConfigurationTechniqueGenerator.generate(4, 129)
        assertEquals(24, square.entry)
        assertEquals(3, square.remainder)
        assertEquals(
            listOf(
                listOf(32, 35, 38, 24),
                listOf(37, 25, 31, 36),
                listOf(26, 40, 33, 30),
                listOf(34, 29, 27, 39),
            ),
            square.grid.map { it.toList() },
        )
    }

    @Test
    fun subtraction_constants() {
        assertEquals(12, KhatimType.MOUSSALAS.subtractionConstant)
        assertEquals(30, KhatimType.MOURABBA.subtractionConstant)
        assertEquals(60, KhatimType.MOUKHAMAS.subtractionConstant)
        assertEquals(105, KhatimType.MOUSSADIS.subtractionConstant)
        assertEquals(168, KhatimType.MOUSSABBIA.subtractionConstant)
        assertEquals(252, KhatimType.MOUTHAMIN.subtractionConstant)
        assertEquals(360, KhatimType.MOUTASSI.subtractionConstant)
    }
}

class AbjadTest {

    @Test
    fun latif_oriental_and_occidental() {
        // لطيف : ل=30 ط=9 ي=10 ف=80 → 129 (même dans les deux systèmes pour ces lettres)
        val oriental = AbjadTables.computeMysticalWeight("لطيف", AbjadSystem.ORIENTAL)
        val occidental = AbjadTables.computeMysticalWeight("لطيف", AbjadSystem.OCCIDENTAL)
        assertEquals(129, oriental.weight)
        assertEquals(129, occidental.weight)
    }

    @Test
    fun western_vs_eastern_shin() {
        // ش = 300 oriental, 1000 occidental
        assertEquals(300, AbjadTables.valueOf('ش', AbjadSystem.ORIENTAL))
        assertEquals(1000, AbjadTables.valueOf('ش', AbjadSystem.OCCIDENTAL))
    }

    @Test
    fun number_to_letters_156_wanaq() {
        // 156 = 6+50+100 → ونق
        assertEquals("ونق", AbjadTables.numberToLettersOrdered(156, AbjadSystem.OCCIDENTAL))
    }

    @Test
    fun empty_text_error() {
        val r = AbjadTables.computeMysticalWeight("", AbjadSystem.ORIENTAL)
        assertTrue(!r.isSuccess)
    }
}

class SpiritExtractionTest {

    @Test
    fun cle_207_celestial_and_terrestrial() {
        val spirit = SpiritNameExtractor.extractForValue("Clé", 207)
        assertEquals("ونقياءيل", spirit.celestialArabic)
        assertEquals(3, spirit.revolutionsAdded)
        // 207 + 360*3 - 1019 = 1287 - 1019 = 268 → حصر
        assertTrue(spirit.terrestrialArabic.startsWith("حصر"))
        assertTrue(spirit.terrestrialArabic.endsWith("طيش"))
    }
}

class BaseLayoutTest {

    @Test
    fun all_orders_3_to_9_are_magic() {
        for (n in listOf(3, 4, 5, 6, 7, 8, 9)) {
            val layout = BaseLayouts.houseLayout(n)
            assertTrue(BaseLayouts.isMagic(layout), "Layout $n should be magic")
        }
    }
}

class ServiceIntegrationTest {

    @Test
    fun full_generation_moussabbia_advanced() {
        val result = KhatimGeneratorService.generate(
            type = KhatimType.MOUSSABBIA,
            method = ConstructionMethod.ADVANCED_CONFIGURATION,
            mysticalWeight = 1946,
        )
        assertTrue(result.isSuccess, result.exceptionOrNull()?.message)
        val khatim = result.getOrThrow()
        assertEquals(7, khatim.square.order)
        assertEquals(1946, khatim.characteristics.wafq)
        assertTrue(khatim.spirits.size == 7)
    }

    @Test
    fun border_method_rejects_even_order() {
        val result = KhatimGeneratorService.generate(
            type = KhatimType.MOURABBA,
            method = ConstructionMethod.FROM_INTERIOR,
            mysticalWeight = 34,
        )
        assertTrue(result.isFailure)
    }
}
