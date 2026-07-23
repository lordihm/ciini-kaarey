package com.ciini.kaarey.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ciini.kaarey.abjad.AbjadResult
import com.ciini.kaarey.model.AbjadSystem
import com.ciini.kaarey.model.ConstructionMethod
import com.ciini.kaarey.model.KhatimResult
import com.ciini.kaarey.model.KhatimType
import com.ciini.kaarey.model.PmInputMode
import com.ciini.kaarey.service.KhatimGeneratorService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

data class KhatimUiState(
    val selectedType: KhatimType = KhatimType.MOUSSALAS,
    val selectedMethod: ConstructionMethod = ConstructionMethod.ADVANCED_CONFIGURATION,
    val pmInputMode: PmInputMode = PmInputMode.MANUAL,
    val manualPmText: String = "15",
    val arabicText: String = "",
    val abjadSystem: AbjadSystem = AbjadSystem.OCCIDENTAL,
    val abjadPreview: AbjadResult? = null,
    val isGenerating: Boolean = false,
    val result: KhatimResult? = null,
    val errorMessage: String? = null,
    val infoMessage: String? = null,
)

class KhatimViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(KhatimUiState())
    val uiState: StateFlow<KhatimUiState> = _uiState.asStateFlow()

    fun onTypeSelected(type: KhatimType) {
        _uiState.update {
            it.copy(
                selectedType = type,
                manualPmText = KhatimGeneratorService.defaultPm(type).toString(),
                errorMessage = null,
                result = null,
            )
        }
        // Si méthode de bordures + ordre pair → basculer vers config avancée
        if (type.order % 2 == 0 &&
            _uiState.value.selectedMethod != ConstructionMethod.ADVANCED_CONFIGURATION
        ) {
            onMethodSelected(ConstructionMethod.ADVANCED_CONFIGURATION)
            _uiState.update {
                it.copy(
                    infoMessage = "Les méthodes de bordures sont réservées aux dimensions " +
                        "impaires. Configuration Avancée sélectionnée.",
                )
            }
        }
    }

    fun onMethodSelected(method: ConstructionMethod) {
        val type = _uiState.value.selectedType
        if (method != ConstructionMethod.ADVANCED_CONFIGURATION && type.order % 2 == 0) {
            _uiState.update {
                it.copy(
                    errorMessage = "Les méthodes de bordures nécessitent une dimension impaire " +
                        "(3, 5, 7 ou 9).",
                )
            }
            return
        }
        _uiState.update {
            it.copy(selectedMethod = method, errorMessage = null, infoMessage = null)
        }
    }

    fun onPmModeSelected(mode: PmInputMode) {
        _uiState.update { it.copy(pmInputMode = mode, errorMessage = null) }
        if (mode == PmInputMode.ARABIC_TEXT) {
            refreshAbjadPreview()
        }
    }

    fun onManualPmChanged(text: String) {
        _uiState.update { it.copy(manualPmText = text.filter { ch -> ch.isDigit() }, errorMessage = null) }
    }

    fun onArabicTextChanged(text: String) {
        _uiState.update { it.copy(arabicText = text, errorMessage = null) }
        refreshAbjadPreview()
    }

    fun onAbjadSystemSelected(system: AbjadSystem) {
        _uiState.update { it.copy(abjadSystem = system) }
        refreshAbjadPreview()
    }

    fun clearMessages() {
        _uiState.update { it.copy(errorMessage = null, infoMessage = null) }
    }

    private fun refreshAbjadPreview() {
        val state = _uiState.value
        if (state.arabicText.isBlank()) {
            _uiState.update { it.copy(abjadPreview = null) }
            return
        }
        val preview = KhatimGeneratorService.computeAbjad(state.arabicText, state.abjadSystem)
        _uiState.update { it.copy(abjadPreview = preview) }
    }

    fun generate() {
        val state = _uiState.value
        val pm = resolvePm(state) ?: return

        _uiState.update { it.copy(isGenerating = true, errorMessage = null, infoMessage = null) }

        viewModelScope.launch {
            val outcome = withContext(Dispatchers.Default) {
                KhatimGeneratorService.generate(
                    type = state.selectedType,
                    method = state.selectedMethod,
                    mysticalWeight = pm,
                )
            }
            outcome.fold(
                onSuccess = { result ->
                    _uiState.update {
                        it.copy(
                            isGenerating = false,
                            result = result,
                            errorMessage = null,
                            infoMessage = if (!result.isBalanced) {
                                "Carré généré. Note : avec un reste non nul, les diagonales " +
                                    "peuvent différer du WAFQ (comportement documenté)."
                            } else null,
                        )
                    }
                },
                onFailure = { err ->
                    _uiState.update {
                        it.copy(
                            isGenerating = false,
                            result = null,
                            errorMessage = err.message ?: "Erreur de génération inconnue.",
                        )
                    }
                },
            )
        }
    }

    private fun resolvePm(state: KhatimUiState): Int? {
        return when (state.pmInputMode) {
            PmInputMode.MANUAL -> {
                val value = state.manualPmText.toIntOrNull()
                if (value == null || value <= 0) {
                    _uiState.update {
                        it.copy(errorMessage = "Veuillez saisir un Poids Mystique entier positif.")
                    }
                    null
                } else {
                    value
                }
            }

            PmInputMode.ARABIC_TEXT -> {
                val preview = state.abjadPreview
                    ?: KhatimGeneratorService.computeAbjad(state.arabicText, state.abjadSystem)
                if (!preview.isSuccess) {
                    _uiState.update {
                        it.copy(
                            errorMessage = preview.error
                                ?: "Impossible de calculer le PM à partir du texte arabe.",
                        )
                    }
                    null
                } else {
                    preview.weight
                }
            }
        }
    }
}
