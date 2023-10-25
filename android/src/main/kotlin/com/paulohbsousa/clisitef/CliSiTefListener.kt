package com.paulohbsousa.clisitef


import android.os.Handler
import android.os.Looper
import android.os.Message
import br.com.softwareexpress.sitef.android.CliSiTef
import br.com.softwareexpress.sitef.android.CliSiTefI
import br.com.softwareexpress.sitef.android.ICliSiTefListener
import io.flutter.Log
import io.flutter.plugin.common.EventChannel.EventSink
import java.lang.Exception

class CliSiTefListener(private val cliSiTef: CliSiTef): ICliSiTefListener {

    private var dataSink: EventSink? = null

    private var eventSink: EventSink? = null

    override fun onData(
        currentStage: Int,
        command: Int,
        fieldId: Int,
        minLength: Int,
        maxLength: Int,
        input: ByteArray?
    ) {
        val data = ""
        var clisitefData: CliSiTefData? = null

        when(command) {
            CliSiTef.CMD_SHOW_MSG_CASHIER,
            CliSiTef.CMD_CLEAR_MSG_CASHIER_CUSTOMER,
            CliSiTef.CMD_SHOW_MSG_CASHIER_CUSTOMER,
            CliSiTef.CMD_SHOW_MSG_CUSTOMER -> clisitefData = CliSiTefData(DataEvents.MESSAGE, currentStage, cliSiTef.buffer)
            CliSiTef.CMD_PRESS_ANY_KEY -> clisitefData = CliSiTefData(DataEvents.PRESS_ANY_KEY, currentStage, cliSiTef.buffer)
            CliSiTef.CMD_SHOW_MENU_TITLE,
            CliSiTef.CMD_CLEAR_MENU_TITLE -> clisitefData = CliSiTefData(DataEvents.MENU_TITLE, currentStage, cliSiTef.buffer)
            CliSiTef.CMD_GET_MENU_OPTION -> clisitefData = CliSiTefData(DataEvents.MENU_OPTIONS, currentStage, cliSiTef.buffer, false)
            CliSiTef.CMD_GET_FIELD,
            CliSiTef.CMD_GET_FIELD_BARCODE,
            CliSiTef.CMD_GET_FIELD_CURRENCY -> clisitefData = CliSiTefData(DataEvents.GET_FIELD, currentStage, cliSiTef.buffer, false, maxLength = maxLength, minLength = minLength)
            CliSiTef.CMD_RESULT_DATA -> clisitefData = CliSiTefData(DataEvents.DATA, currentStage, cliSiTef.buffer, true, fieldId)
            else -> Log.i("CliSiTefListener", "onData Default case for command $command")
        }

        if (clisitefData != null) {
            dataSink?.success(clisitefData.toDataSink())
            if (clisitefData.shouldContinue) {
                cliSiTef.continueTransaction(data)
            }
        } else {
            cliSiTef.continueTransaction(data)
        }
    }

    override fun onTransactionResult(currentStage: Int, resultCode: Int) {
        if (currentStage == 1) {
            if (resultCode == 0) {
                try {
                    cliSiTef.finishTransaction(1)
                    eventSink?.success(TransactionEvents.TRANSACTION_CONFIRM.named)
                } catch (e: Exception) {
                    eventSink?.error(TransactionEvents.TRANSACTION_FAILED.named, e.toString(), e)
                }
            }
        } else {
            if (resultCode == 0) {
                eventSink?.success(TransactionEvents.TRANSACTION_OK.named)
            }
        }
        eventSink?.error(TransactionEvents.TRANSACTION_ERROR.named, null, null)
    }

    fun setEventSink(sink: EventSink?) {
        eventSink = sink
    }

    fun setDataSink(sink: EventSink?) {
        dataSink = sink
    }

    fun onMessage(looper: Looper) = Handler(looper) {
        message ->
        when (message.what) {
            CliSiTefI.EVT_INICIA_ATIVACAO_BT -> eventSink?.success(PinPadEvents.START_BLUETOOTH.named)
            CliSiTefI.EVT_FIM_ATIVACAO_BT -> eventSink?.success(PinPadEvents.END_BLUETOOTH.named)
            CliSiTefI.EVT_INICIA_AGUARDA_CONEXAO_PP -> eventSink?.success(PinPadEvents.WAITING_PINPAD_CONNECTION.named)
            CliSiTefI.EVT_FIM_AGUARDA_CONEXAO_PP -> eventSink?.success(PinPadEvents.PINPAD_OK.named)
            CliSiTefI.EVT_PP_BT_CONFIGURANDO -> eventSink?.success(PinPadEvents.WAITING_PINPAD_BLUETOOTH.named)
            CliSiTefI.EVT_PP_BT_CONFIGURADO -> eventSink?.success(PinPadEvents.PINPAD_BLUETOOTH_CONNECTED.named)
            CliSiTefI.EVT_PP_BT_DESCONECTADO -> eventSink?.success(PinPadEvents.PINPAD_BLUETOOTH_DISCONNECTED.named)
            else -> eventSink?.error(PinPadEvents.GENERIC_ERROR.named, message.what.toString(), message)
        }
        true
    }
}