# Ciini Kaarey — Générateur de Khatim (Carrés Magiques Soufis)

Application Android Kotlin pour configurer et générer des **Khatim** (خواتم) selon les méthodes traditionnelles soufies et les documents de référence :

- *Technique de configuration des Khatims*
- *Des caractéristiques, propriétés et usages des Khawatim*
- *Les carrés magiques dans la tradition mathématique arabe* (martin38 — Yves Martin)

## Fonctionnalités (V1)

- **7 dimensions** : Moussalas (3×3) → Moutassi (9×9), avec usages et planète associés
- **3 méthodes de construction**
  1. À partir de l'intérieur (bordures concentriques) — dimensions impaires
  2. À partir de l'extérieur (bordures) — dimensions impaires
  3. Configuration avancée (soustraction du PM, division, gestion des restes)
- **Poids Mystique (PM)** : saisie manuelle ou calcul Abjad depuis un texte arabe  
  (comput occidental *et* oriental)
- **Caractéristiques** : Clé, Verrou, Médiane, WAFQ, Aire, Force, But
- **Esprits-servants** : extraction céleste (−51 + ياءيل) et terrestre (−1019 / +360 + طيش)
- **Couplage Mourabba** (4×4) par colonnes pour Latîf et cas similaires

## Architecture

```
:core   → logique pure Kotlin (JVM) : Abjad, générateurs, esprits
:app    → Android UI Jetpack Compose + MVVM (StateFlow, Coroutines)
```

## Prérequis

- Android Studio Hedgehog+ / JDK 17+
- Android SDK 34
- minSdk 26

## Build

```bash
./gradlew :core:test          # tests unitaires des algorithmes
./gradlew :app:assembleDebug  # APK debug
```

Ouvrir le projet dans Android Studio, laisser Gradle synchroniser, puis Run sur un appareil/émulateur.

## Exemples validés par les tests

| Cas | Résultat attendu |
|-----|------------------|
| PM 1947, 3×3, reste 0 | Entrée 645, grille documentée, sommes = 1947 |
| PM 635, 3×3, reste 2 | Entrée 207, Clé 207, Verrou 216 |
| PM 129 (لطيف), 4×4 | Mourabba de Latîf (reste 3) |
| Esprit Clé 207 | ونقياءيل / حصرطيش (+3×360) |

## Workflow utilisateur

1. Choisir le type (ex. Moussabbia 7×7)
2. Choisir la méthode (Configuration Avancée)
3. Saisir le PM (ex. `1946`) ou un texte arabe (ex. `الملك`)
4. Appuyer sur **Générer le Khatim**
5. Consulter la grille, les caractéristiques et les noms d'esprits

## Notes

- La méthode de séparation pairs/impairs (Exemple 3, martin38) est volontairement hors scope V1.
- Le gestionnaire des 99 Noms de Dieu est prévu en V2.
- Les méthodes de bordures exigent un PM tel que `(PM − constante magique)` soit divisible par n ; sinon utiliser la Configuration Avancée (gestion native des restes).

## Licence / usage

Outil éducatif pour pratiquants et chercheurs intéressés par la science des nombres dans la tradition islamique. Respecter le cadre éthique et spirituel associé à ces pratiques.
