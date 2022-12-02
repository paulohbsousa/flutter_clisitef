package com.loopmarket.clisitef.channel

import com.loopmarket.clisitef.CliSiTefListener
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.EventChannel.EventSink

object EventHandler: StreamHandler {
    private var eventSink: EventSink? = null

    private var listener: CliSiTefListener? = null;

    fun setListener(l: CliSiTefListener): EventHandler {
        listener = l
        return this
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
        listener?.setEventSink(eventSink)
    }

    override fun onCancel(p0: Any?) {
        eventSink = null
        listener?.setEventSink(null)
    }
}