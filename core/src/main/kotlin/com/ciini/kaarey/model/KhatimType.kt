package com.ciini.kaarey.model

/**
 * Les 7 types traditionnels de Khatim (khawâtim) et leurs usages documentés.
 */
enum class KhatimType(
    val order: Int,
    val arabicName: String,
    val frenchName: String,
    val planet: String,
    val usageSummary: String,
) {
    MOUSSALAS(
        order = 3,
        arabicName = "مثلث",
        frenchName = "Moussalas",
        planet = "Saturne",
        usageSummary = "Protection, sortie de prison, faciliter un accouchement, " +
            "évincer un ennemi, annihiler un mauvais sort, fructifier les affaires.",
    ),
    MOURABBA(
        order = 4,
        arabicName = "مربع",
        frenchName = "Mourabba",
        planet = "Jupiter",
        usageSummary = "Amour et attirance, prestige, œuvres de bien, " +
            "désenvoutement, victoire et estime auprès des autorités.",
    ),
    MOUKHAMAS(
        order = 5,
        arabicName = "مخمس",
        frenchName = "Moukhamas",
        planet = "Mars",
        usageSummary = "Soigner les maladies, combattre l'hostilité, " +
            "protection et vigueur, quête de l'amour.",
    ),
    MOUSSADIS(
        order = 6,
        arabicName = "مسادس",
        frenchName = "Moussadis",
        planet = "Soleil",
        usageSummary = "Richesse, victoire, succès, estime auprès des régnants, " +
            "faveurs et honneurs.",
    ),
    MOUSSABBIA(
        order = 7,
        arabicName = "مسبع",
        frenchName = "Moussabbia",
        planet = "Vénus",
        usageSummary = "Vaincre l'ennemi, acquisition de la science, " +
            "destruction des mauvais sorts, amour et relations favorables.",
    ),
    MOUTHAMIN(
        order = 8,
        arabicName = "مثمن",
        frenchName = "Mouthamin",
        planet = "Mercure",
        usageSummary = "Richesse, guérison, sciences et entreprises, " +
            "dissimulation, éloquence et mémoire.",
    ),
    MOUTASSI(
        order = 9,
        arabicName = "متسع",
        frenchName = "Moutassi",
        planet = "Lune",
        usageSummary = "Prestige, exaucement, sécurité, amour, " +
            "victoire auprès des princes, extinction des épidémies.",
    );

    val cellCount: Int get() = order * order

    /** Constante à soustraire du PM avant division (n(n²-1)/2). */
    val subtractionConstant: Int get() = order * (order * order - 1) / 2

    val displayLabel: String
        get() = "$frenchName (${order}×${order})"

    companion object {
        fun fromOrder(order: Int): KhatimType =
            entries.first { it.order == order }
    }
}

enum class ConstructionMethod(val labelFr: String, val descriptionFr: String) {
    FROM_INTERIOR(
        labelFr = "À partir de l'Intérieur (bordures)",
        descriptionFr = "Méthode des bordures concentriques, de l'intérieur vers l'extérieur " +
            "(dimensions impaires — Exemple 1, martin38).",
    ),
    FROM_EXTERIOR(
        labelFr = "À partir de l'Extérieur (bordures)",
        descriptionFr = "Méthode des bordures, de l'extérieur vers l'intérieur " +
            "(dimensions impaires — Exemple 2, martin38).",
    ),
    ADVANCED_CONFIGURATION(
        labelFr = "Configuration Avancée",
        descriptionFr = "Technique de configuration des khatims : soustraction du PM, " +
            "division, gestion des restes et placement des incréments.",
    ),
}

enum class AbjadSystem(val labelFr: String) {
    OCCIDENTAL("Comput occidental (Maghrébin)"),
    ORIENTAL("Comput oriental (Mashriqi)"),
}

enum class PmInputMode(val labelFr: String) {
    MANUAL("Saisie manuelle du PM"),
    ARABIC_TEXT("Calcul via orthographe arabe (Abrégé)"),
}
