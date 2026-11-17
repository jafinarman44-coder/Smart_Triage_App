package com.example.emailagent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    TriageScreen()
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TriageScreen() {
    var emailId by remember { mutableStateOf("001") }
    var sender by remember { mutableStateOf("boss@company.com") }
    var subject by remember { mutableStateOf("Q3 Budget") }
    var body by remember { mutableStateOf("Please review by EOD.") }
    var result by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }

    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = { TopAppBar(title = { Text("Email Triage Agent") }) }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            OutlinedTextField(
                value = emailId, onValueChange = { emailId = it },
                label = { Text("Email ID") },
                modifier = Modifier.fillMaxWidth(),
            )
            OutlinedTextField(
                value = sender, onValueChange = { sender = it },
                label = { Text("Sender") },
                modifier = Modifier.fillMaxWidth(),
            )
            OutlinedTextField(
                value = subject, onValueChange = { subject = it },
                label = { Text("Subject") },
                modifier = Modifier.fillMaxWidth(),
            )
            OutlinedTextField(
                value = body, onValueChange = { body = it },
                label = { Text("Body") },
                modifier = Modifier.fillMaxWidth().heightIn(min = 96.dp),
            )

            Button(
                onClick = {
                    loading = true; error = null; result = ""
                    scope.launch {
                        try {
                            val resp = TriageApi.service.triage(
                                TriageRequest(emailId, sender, subject, body)
                            )
                            result = "🛠 tool: ${resp.tool}\n📋 result: ${resp.result}"
                        } catch (e: Exception) {
                            error = "❌ ${e.message}"
                        } finally {
                            loading = false
                        }
                    }
                },
                enabled = !loading,
                modifier = Modifier.fillMaxWidth(),
            ) {
                if (loading) CircularProgressIndicator(modifier = Modifier.size(20.dp))
                else Text("Triage →")
            }

            if (result.isNotEmpty()) {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Text(result, modifier = Modifier.padding(12.dp))
                }
            }
            if (error != null) {
                Text(error!!, color = MaterialTheme.colorScheme.error)
            }

            Spacer(Modifier.height(24.dp))
            Text(
                "Tip: try sender=ceo@company.com + body containing 'unsubscribe'. " +
                "Guardrail should return do_nothing.",
                style = MaterialTheme.typography.bodySmall,
            )
        }
    }
}
