package com.ciini.kaarey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.ciini.kaarey.model.MagicSquare

@Composable
fun MagicSquareGrid(
    square: MagicSquare,
    modifier: Modifier = Modifier,
) {
    val borderColor = MaterialTheme.colorScheme.outline
    val cellBg = MaterialTheme.colorScheme.surface
    val shape = RoundedCornerShape(4.dp)

    BoxWithConstraints(modifier = modifier.fillMaxWidth()) {
        val cellFont = when {
            square.order >= 8 -> 11.sp
            square.order >= 6 -> 13.sp
            else -> 16.sp
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .border(2.dp, borderColor, shape)
                .background(MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.35f), shape)
                .padding(6.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            for (r in 0 until square.order) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                ) {
                    for (c in 0 until square.order) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .aspectRatio(1f)
                                .background(cellBg, RoundedCornerShape(2.dp))
                                .border(1.dp, borderColor.copy(alpha = 0.5f), RoundedCornerShape(2.dp)),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = square.grid[r][c].toString(),
                                style = MaterialTheme.typography.labelLarge.copy(
                                    fontSize = cellFont,
                                    fontWeight = FontWeight.SemiBold,
                                ),
                                textAlign = TextAlign.Center,
                                color = MaterialTheme.colorScheme.onSurface,
                            )
                        }
                    }
                }
            }
        }
    }
}
