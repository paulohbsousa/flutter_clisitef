package com.loopmarket.clisitef

import android.annotation.SuppressLint
import android.util.Log
import br.com.softwareexpress.sitef.android.CliSiTef

class PinPadMethods(cliSiTef: CliSiTef): SiTefClient(cliSiTef) {
    fun setDisplayMessage(message: String) {
        success(cliSiTef.pinpad.setDisplayMessage(message))
    }

    fun readYesOrNo(message: String) {
        success(cliSiTef.pinpad.readYesNo(message))
    }

    @SuppressLint("LongLogTag")
    fun isPresent() {
        try {
            success(cliSiTef.pinpad.isPresent)
        } catch (e: Exception) {
            success(false)
        } catch (e: Error) {
            Log.e("PinPadMethods::isPresent", e.toString());
            success(false)
        }
    }
}