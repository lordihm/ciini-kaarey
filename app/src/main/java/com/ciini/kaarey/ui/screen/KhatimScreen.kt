package com.ciini.kaarey.ui.screen

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ciini.kaarey.model.AbjadSystem
import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.KhatimResult
import com.ciini.kaarey.model.KhatimType
import com.ciini.kaarey.model.PmInputMode
import com.ciini.kaarey.model.SpiritKind
import com.ciini.kaarey.ui.components.MagicSquareGrid
import com.ciini.kaarey.viewmodel.KhatimViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun KhatimScreen(
    viewModel: KhatimViewModel = viewModel(),
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Ciini Kaarey",
                            style = MaterialTheme.typography.titleLarge,
                        )
                        Text(
                            text = "خواتم — Carrés magiques soufis",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.85f),
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                ),
            )
        },
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            item {
                SectionCard(title = "1. Type de Khatim") {
                    EnumDropdown(
                        label = "Dimension",
                        options = KhatimType.entries,
                        selected = state.selectedType,
                        optionLabel = { it.displayLabel },
                        onSelected = viewModel::onTypeSelected,
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = "Planète : ${state.selectedType.planet}",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.secondary,
                    )
                    Text(
                        text = state.selectedType.usageSummary,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(top = 4.dp),
                    )
                }
            }

            item {
                SectionCard(title = "2. Méthode de construction") {
                    EnumDropdown(
                        label = "Méthode",
                        options = ConstructionMethod.entries,
                        selected = state.selectedMethod,
                        optionLabel = { it.labelFr },
                        onSelected = viewModel::onMethodSelected,
                    )
                    Text(
                        text = state.selectedMethod.descriptionFr,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(top = 8.dp),
                    )
                }
            }

            item {
                SectionCard(title = "3. Poids Mystique (PM)") {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        PmInputMode.entries.forEach { mode ->
                            FilterChip(
                                selected = state.pmInputMode == mode,
                                onClick = { viewModel.onPmModeSelected(mode) },
                                label = { Text(mode.labelFr) },
                                modifier = Modifier.fillMaxWidth(),
                            )
                        }
                    }
                    Spacer(Modifier.height(12.dp))

                    when (state.pmInputMode) {
                        PmInputMode.MANUAL -> {
                            OutlinedTextField(
                                value = state.manualPmText,
                                onValueChange = viewModel::onManualPmChanged,
                                label = { Text("Poids Mystique") },
                                singleLine = true,
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                modifier = Modifier.fillMaxWidth(),
                            )
                        }

                        PmInputMode.ARABIC_TEXT -> {
                            EnumDropdown(
                                label = "Système Abjad",
                                options = AbjadSystem.entries,
                                selected = state.abjadSystem,
                                optionLabel = { it.labelFr },
                                onSelected = viewModel::onAbjadSystemSelected,
                            )
                            Spacer(Modifier.height(8.dp))
                            OutlinedTextField(
                                value = state.arabicText,
                                onValueChange = viewModel::onArabicTextChanged,
                                label = { Text("Texte arabe (ex. لطيف)") },
                                singleLine = false,
                                minLines = 2,
                                modifier = Modifier.fillMaxWidth(),
                                textStyle = MaterialTheme.typography.titleLarge.copy(
                                    textAlign = TextAlign.End,
                                    textDirection = TextDirection.Rtl,
                                ),
                            )
                            state.abjadPreview?.let { preview ->
                                Spacer(Modifier.height(8.dp))
                                if (preview.isSuccess) {
                                    Text(
                                        text = "PM calculé : ${preview.weight}",
                                        style = MaterialTheme.typography.titleMedium,
                                        color = MaterialTheme.colorScheme.tertiary,
                                    )
                                    Text(
                                        text = preview.letterBreakdown.joinToString(" + ") {
                                            "${it.letter}=${it.value}"
                                        },
                                        style = MaterialTheme.typography.bodyMedium,
                                    )
                                } else {
                                    Text(
                                        text = preview.error.orEmpty(),
                                        color = MaterialTheme.colorScheme.error,
                                    )
                                }
                            }
                        }
                    }
                }
            }

            item {
                Button(
                    onClick = viewModel::generate,
                    enabled = !state.isGenerating,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(10.dp),
                ) {
                    if (state.isGenerating) {
                        CircularProgressIndicator(
                            color = MaterialTheme.colorScheme.onPrimary,
                            strokeWidth = 2.dp,
                            modifier = Modifier.height(24.dp),
                        )
                    } else {
                        Text("Générer le Khatim", style = MaterialTheme.typography.titleMedium)
                    }
                }
            }

            state.errorMessage?.let { msg ->
                item {
                    Text(
                        text = msg,
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(
                                MaterialTheme.colorScheme.error.copy(alpha = 0.1f),
                                RoundedCornerShape(8.dp),
                            )
                            .padding(12.dp),
                    )
                }
            }

            state.infoMessage?.let { msg ->
                item {
                    Text(
                        text = msg,
                        color = MaterialTheme.colorScheme.tertiary,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
            }

            state.result?.let { result ->
                item {
                    AnimatedVisibility(
                        visible = true,
                        enter = fadeIn() + slideInVertically { it / 4 },
                        exit = fadeOut(),
                    ) {
                        ResultSection(result)
                    }
                }
            }

            item { Spacer(Modifier.height(24.dp)) }
        }
    }
}

@Composable
private fun ResultSection(result: KhatimResult) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        SectionCard(title = "Khatim généré — ${result.type.displayLabel}") {
            Text(
                text = "Entrée=${result.square.entry} · Sortie=${result.square.exit} · " +
                    "Reste=${result.square.remainder} · Méthode=${result.square.method.labelFr}",
                style = MaterialTheme.typography.bodyMedium,
            )
            Spacer(Modifier.height(12.dp))
            MagicSquareGrid(square = result.square)
            Spacer(Modifier.height(8.dp))
            Text(
                text = if (result.isBalanced) {
                    "✓ Équilibré — lignes et colonnes = ${result.characteristics.wafq}"
                } else {
                    "Sommes lignes : ${result.rowSums} · colonnes : ${result.columnSums}"
                },
                style = MaterialTheme.typography.bodyMedium,
                color = if (result.isBalanced) {
                    MaterialTheme.colorScheme.tertiary
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant
                },
            )
        }

        SectionCard(title = "Caractéristiques") {
            result.characteristics.asLabeledList().forEach { (label, value) ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Text(label, style = MaterialTheme.typography.bodyMedium)
                    Text(
                        value.toString(),
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.secondary,
                    )
                }
                HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f))
            }
        }

        SectionCard(title = "Esprits-servants (Rawhân)") {
            Text(
                text = "Céleste : valeur − 51 + ياءيل · Terrestre : (−1019, +360 si besoin) + طيش",
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(bottom = 8.dp),
            )
            result.spirits.forEach { spirit ->
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp)
                        .background(
                            MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f),
                            RoundedCornerShape(8.dp),
                        )
                        .padding(12.dp),
                ) {
                    Text(
                        text = "${spirit.sourceLabel} = ${spirit.sourceValue}",
                        style = MaterialTheme.typography.titleMedium,
                    )
                    Text(
                        text = "علوي : ${spirit.celestialArabic}",
                        style = MaterialTheme.typography.bodyLarge.copy(
                            textDirection = TextDirection.Rtl,
                        ),
                        textAlign = TextAlign.End,
                        modifier = Modifier.fillMaxWidth(),
                    )
                    Text(
                        text = spirit.celestialLatin,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Text(
                        text = "سفلي : ${spirit.terrestrialArabic}" +
                            if (spirit.revolutionsAdded > 0) {
                                " (+${spirit.revolutionsAdded}×360)"
                            } else "",
                        style = MaterialTheme.typography.bodyLarge.copy(
                            textDirection = TextDirection.Rtl,
                        ),
                        textAlign = TextAlign.End,
                        modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
                    )
                    Text(
                        text = spirit.terrestrialLatin,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }

        if (result.pairedSpirits.isNotEmpty()) {
            SectionCard(title = "Couplage Mourabba (par colonnes)") {
                val terrestrial = result.pairedSpirits.filter { it.kind == SpiritKind.TERRESTRIAL }
                val celestial = result.pairedSpirits.filter { it.kind == SpiritKind.CELESTIAL }

                Text("Esprits terrestres (سفلي)", style = MaterialTheme.typography.titleMedium)
                terrestrial.forEach { p ->
                    Text(
                        "${p.first}/${p.second} → ${p.arabic} (${p.latin})",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(vertical = 2.dp),
                    )
                }
                Spacer(Modifier.height(8.dp))
                Text("Esprits célestes (علوي)", style = MaterialTheme.typography.titleMedium)
                celestial.forEach { p ->
                    Text(
                        "${p.first}/${p.second} → ${p.arabic} (${p.latin})",
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(vertical = 2.dp),
                    )
                }
            }
        }
    }
}

@Composable
private fun SectionCard(
    title: String,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                MaterialTheme.colorScheme.surface,
                RoundedCornerShape(12.dp),
            )
            .padding(16.dp),
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.primary,
        )
        Spacer(Modifier.height(12.dp))
        content()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun <T> EnumDropdown(
    label: String,
    options: List<T>,
    selected: T,
    optionLabel: (T) -> String,
    onSelected: (T) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
    ) {
        OutlinedTextField(
            value = optionLabel(selected),
            onValueChange = {},
            readOnly = true,
            label = { Text(label) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(MenuAnchorType.PrimaryNotEditable),
        )
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(optionLabel(option)) },
                    onClick = {
                        onSelected(option)
                        expanded = false
                    },
                )
            }
        }
    }
}
