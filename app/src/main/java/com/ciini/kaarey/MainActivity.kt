package com.ciini.kaarey

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.ciini.kaarey.ui.screen.KhatimScreen
import com.ciini.kaarey.ui.theme.KhatimTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            KhatimTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    KhatimScreen()
                }
            }
        }
    }
}
