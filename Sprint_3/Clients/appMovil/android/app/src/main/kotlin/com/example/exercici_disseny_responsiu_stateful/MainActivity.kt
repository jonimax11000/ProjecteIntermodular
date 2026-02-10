package com.example.exercici_disseny_responsiu_stateful

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import javax.net.ssl.HttpsURLConnection

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        HttpsURLConnection.setDefaultHostnameVerifier { hostname, session -> true }
    }
}
