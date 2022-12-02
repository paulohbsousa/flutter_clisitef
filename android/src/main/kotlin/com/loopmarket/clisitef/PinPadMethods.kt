package com.loopmarket.clisitef

import br.com.softwareexpress.sitef.android.CliSiTef

class PinPadMethods(cliSiTef: CliSiTef): SiTefClient(cliSiTef) {
    fun setDisplayMessage(message: String) {
        success(cliSiTef.pinpad.setDisplayMessage(message))
    }

    fun readYesOrNo(message: String) {
        success(cliSiTef.pinpad.readYesNo(message))
    }

    fun isPresent() {
        try {
            success(cliSiTef.pinpad.isPresent)
        } catch (e: Exception) {
            success(false)
        }
    }
}