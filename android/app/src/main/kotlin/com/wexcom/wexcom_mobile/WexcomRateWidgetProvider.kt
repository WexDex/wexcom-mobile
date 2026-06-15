package com.wexcom.wexcom_mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WexcomRateWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val defaultCode = widgetData.getString("default_currency", "DZD") ?: "DZD"
        val currency = widgetData.getString("rate_currency", "USD") ?: "USD"
        val rate = widgetData.getString("rate_$currency", "—") ?: "—"
        val label = "1 $currency = $rate $defaultCode"

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.wexcom_rate_widget).apply {
                setTextViewText(R.id.rate_label, label)
                setOnClickPendingIntent(
                    R.id.rate_container,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("wexcom://tags?segment=currencies"),
                    ),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
