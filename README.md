# Ciini Kaarey — Générateur de Khatim (Flutter)

Application **Flutter** (Android & iOS) pour configurer, générer et analyser des **Khatim** (خواتم), les carrés magiques de la tradition soufie. Réécriture cross-platform de l'application Android Kotlin d'origine.

Basée sur les documents de référence :
- *Technique de configuration des Khatims*
- *Des caractéristiques, propriétés et usages des Khawatim*
- *Les carrés magiques dans la tradition mathématique arabe* (martin38)

## Fonctionnalités

- **7 dimensions** : Moussalas (3×3) → Moutassi (9×9), avec usages et planète associés.
- **3 méthodes de construction** :
  1. Configuration Avancée (soustraction du PM, division, gestion des restes) — cœur de la méthode traditionnelle.
  2. Bordures — Intérieur vers Extérieur (dimensions impaires).
  3. Bordures — Extérieur vers Intérieur (dimensions impaires).
- **Poids Mystique (PM)** : saisie manuelle *ou* calcul Abjad d'un texte arabe (comput **occidental** et **oriental**).
- **Caractéristiques** : Clé (مفتاح), Verrou (مغلاق), Médiane (عدل), WAFQ (وفق), Aire (مساحة), Force (ضابط), But (غاية).
- **Esprits-servants** : extraction céleste (−51 + ياءيل) et terrestre (−1019 / +360 + طيش), plus couplage Mourabba 4×4 par colonnes.
- **Historique** persistant (jusqu'à 100 Khatim), **thème** clair/sombre/système, **export PDF** et **partage**.
- Interface **française**, textes arabes en RTL, localisation FR/AR.

## Architecture (MVVM + Provider)

```
lib/
├── main.dart
├── core/                      # Logique métier pure (testable, sans Flutter)
│   ├── models/                # Khatim, Spirit, KhatimDimension, KhatimCharacteristics
│   ├── generators/            # khatim_generator (+ générateurs par dimension)
│   ├── calculators/           # abjad, esprits, caractéristiques
│   └── constants/             # abjad_values, layout_configs
├── ui/
│   ├── screens/               # home, configuration, generation, result, history
│   ├── widgets/               # khatim_grid, sélecteurs, affichages
│   ├── providers/             # khatim / settings / history (ChangeNotifier)
│   └── themes/                # app_theme, light_theme, dark_theme
├── services/                  # storage (SharedPreferences), export (PDF/partage)
└── utils/                     # validators, formatters, extensions
```

La génération lourde (jusqu'au 9×9) s'exécute dans un **isolate** via `compute()`.

## Algorithme (Technique de configuration)

Pour un PM et une dimension `n` :

1. `subtracted = PM − C` où `C = n(n²−1)/2` (12, 30, 60, 105, 168, 252, 360).
2. `entrée = subtracted ÷ n` ; `reste = subtracted mod n`.
3. On incrémente (+1) les `n·reste` plus grandes « maisons » du lay-out ; valeur = `entrée + (maison − 1)`.
4. Vérification de la magicité ; repli sur un placement équilibré garanti si nécessaire.

Les lay-outs 3→7 sont les dispositions traditionnelles (vérifiées). Les ordres 8 et 9 sont construits algorithmiquement (GF(8) et construction linéaire) pour garantir des lignes/colonnes équilibrées et des valeurs distinctes pour **tous** les restes.

> **Note mathématique** : il n'existe aucun carré gréco-latin d'ordre 6. Pour un Moussadis (6×6) avec reste ≠ 0, la somme des colonnes (WAFQ) reste exacte, mais une valeur peut se répéter — c'est une limitation intrinsèque, cohérente avec les particularités des documents sources pour cette taille.

## Exemples validés par les tests

| Cas | Résultat |
|-----|----------|
| PM 1947, 3×3 (reste 0) | `648 653 646 / 647 649 651 / 652 645 650` |
| PM 1948 / 1949, 3×3 (restes 1, 2) | grilles documentées |
| PM 635, 3×3 (reste 2) | `211 216 208 / 209 212 214 / 215 207 213` ; Clé 207, Verrou 216, WAFQ 635 |
| PM 1950, 4×4 (reste 0) | grille documentée (WAFQ 1950) |
| PM 129 (لطيف), 4×4 (reste 3) | Mourabba de Latîf |
| PM 1950 / 1946, 5×5 / 7×7 | grilles documentées |
| Clé 207 → esprit | céleste `ونقياءيل`, terrestre `حصر…طيش` (+3×360) |

## Prérequis & Build

- Flutter SDK ≥ 3.4, Dart ≥ 3.4
- Android : SDK 34, minSdk 21+ (Android Studio). iOS : Xcode.

```bash
flutter pub get
flutter test                 # tests unitaires + widget
flutter analyze              # lint
flutter run                  # sur appareil/émulateur
flutter build apk --release  # Android
flutter build ios --release  # iOS (sur macOS)
```

## Dépendances principales

`provider`, `shared_preferences`, `google_fonts`, `pdf` + `printing`, `share_plus`, `path_provider`, `intl`, `equatable`.

## Roadmap

- V2 : gestionnaire des 99 Noms de Dieu, synchronisation cloud.
- V3 : analyse de compatibilité, compositions multi-Khatim.

## Avertissement

Outil **éducatif** destiné aux pratiquants et chercheurs en science des nombres de la tradition islamique. Merci de respecter le cadre éthique et spirituel associé à ces pratiques.
