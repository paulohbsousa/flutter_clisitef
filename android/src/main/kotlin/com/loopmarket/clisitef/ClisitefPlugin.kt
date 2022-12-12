package com.loopmarket.clisitef

import android.os.Looper
import androidx.annotation.NonNull
import br.com.softwareexpress.sitef.android.CliSiTef
import com.loopmarket.clisitef.channel.DataHandler
import com.loopmarket.clisitef.channel.EventHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** ClisitefPlugin */
class ClisitefPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var methodChannel : MethodChannel

  private lateinit var eventChannel : EventChannel

  private lateinit var dataChannel : EventChannel

  private lateinit var cliSiTef: CliSiTef

  private lateinit var tefMethods: TefMethods

  private lateinit var pinPadMethods: PinPadMethods;

  private lateinit var cliSiTefListener: CliSiTefListener;

  private val CHANNEL = "com.loopmarket.clisitef"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    methodChannel.setMethodCallHandler(this)

    cliSiTef = CliSiTef(flutterPluginBinding.applicationContext);

    cliSiTefListener = CliSiTefListener(cliSiTef)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "$CHANNEL/events")
    eventChannel.setStreamHandler(EventHandler.setListener(cliSiTefListener))

    dataChannel = EventChannel(flutterPluginBinding.binaryMessenger, "$CHANNEL/events/data")
    dataChannel.setStreamHandler(DataHandler.setListener(cliSiTefListener))

    cliSiTef.setMessageHandler(cliSiTefListener.onMessage(Looper.getMainLooper()));
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    tefMethods = TefMethods(cliSiTef)
    pinPadMethods = PinPadMethods(cliSiTef)

    tefMethods.setResultHandler(result);
    pinPadMethods.setResultHandler(result);
    when (call.method) {
      "setPinpadDisplayMessage" -> pinPadMethods.setDisplayMessage(call.argument<String>("message")!!)
      "pinpadReadYesNo" -> pinPadMethods.readYesOrNo(call.argument<String>("message")!!)
      "pinpadIsPresent" -> pinPadMethods.isPresent()
      "configure" -> tefMethods.configure(call.argument<String>("enderecoSitef")!!, call.argument<String>("codigoLoja")!!, call.argument<String>("numeroTerminal")!!, "[TipoPinPad=Android_AUTO;]")
      "getQttPendingTransactions" -> tefMethods.getQttPendingTransactions(call.argument<String>("dataFiscal")!!, call.argument<String>("cupomFiscal")!!)
      "startTransaction" -> tefMethods.startTransaction(cliSiTefListener, call.argument<Int>("modalidade")!!, call.argument<String>("valor")!!, call.argument<String>("cupomFiscal")!!, call.argument<String>("dataFiscal")!!, call.argument<String>("horario")!!, call.argument<String>("operador")!!)
      "finishLastTransaction" -> tefMethods.finishLastTransaction(call.argument<Int>("confirma")!!)
      "finishTransaction" -> tefMethods.finishTransaction(call.argument<Int>("confirma")!!, call.argument<String>("cupomFiscal")!!, call.argument<String>("dataFiscal")!!, call.argument<String>("horaFiscal")!!)
      "abortTransaction" -> tefMethods.abortTransaction(call.argument<Int>("continua")!!)
      "continueTransaction" -> tefMethods.continueTransaction(call.argument<String>("data")!!)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    dataChannel.setStreamHandler(null)
  }
}
