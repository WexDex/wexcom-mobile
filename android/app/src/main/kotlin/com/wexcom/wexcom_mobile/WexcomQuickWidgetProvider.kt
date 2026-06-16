package com.wexcom.wexcom_mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WexcomQuickWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.wexcom_quick_widget).apply {
                setOnClickPendingIntent(
                    R.id.btn_new_tx,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("wexcom://transactions?action=new"),
                    ),
                )
                setOnClickPendingIntent(
                    R.id.btn_debt,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("wexcom://transactions?action=new&type=debt"),
                    ),
                )
                setOnClickPendingIntent(
                    R.id.btn_payment,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("wexcom://transactions?action=new&type=payment"),
                    ),
                )
                setOnClickPendingIntent(
                    R.id.btn_roulette,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("wexcom://roulette"),
                    ),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
