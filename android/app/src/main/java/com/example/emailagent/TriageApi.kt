package com.example.emailagent

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import com.google.gson.annotations.SerializedName

data class TriageRequest(
    @SerializedName("email_id") val emailId: String,
    val sender: String,
    val subject: String,
    val body: String,
    val rules: String? = null,
)

data class TriageResponse(
    @SerializedName("email_id") val emailId: String,
    val tool: String,
    val result: String,
)

interface TriageApiService {
    @POST("triage")
    suspend fun triage(@Body req: TriageRequest): TriageResponse
}

object TriageApi {
    // ── Emulator (AVD) → host PC: use 10.0.2.2
    // ── Physical phone on same WiFi → use your PC's LAN IP:
    //    ipconfig → IPv4 Address (e.g. 192.168.1.42) → "http://192.168.1.42:8000/"
    // ── Deployed server → "https://your-app.railway.app/"
    const val BASE_URL = "http://10.0.2.2:8000/"

    val service: TriageApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(TriageApiService::class.java)
    }
}
