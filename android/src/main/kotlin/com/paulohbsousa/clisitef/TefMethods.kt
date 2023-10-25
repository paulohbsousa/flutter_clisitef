package com.paulohbsousa.clisitef

import br.com.softwareexpress.sitef.android.CliSiTef
import br.com.softwareexpress.sitef.android.ICliSiTefListener
import java.lang.Error
import java.lang.Exception

class TefMethods(cliSiTef: CliSiTef): SiTefClient(cliSiTef) {
    var idConfig: Int = 0;

    fun startTransaction(listener: ICliSiTefListener, functionId: Int, trnAmount: String, taxInvoiceNumber: String, taxInvoiceDate: String, taxInvoiceTime: String, cashierOperator: String) {
        processTransactionStatus(cliSiTef.startTransaction(listener, functionId, trnAmount, taxInvoiceNumber, taxInvoiceDate, taxInvoiceTime, cashierOperator, ""))
    }

    fun finishLastTransaction(confirm: Int) {
        try {
            processTransactionStatus(cliSiTef.finishTransaction(confirm))
        } catch (e: Exception) {
            success(false)
        }
    }

    fun finishTransaction(confirm: Int, taxInvoiceNumber: String, taxInvoiceDate: String, taxInvoiceTime: String) {
        try {
            processTransactionStatus(cliSiTef.finishTransaction(confirm, taxInvoiceNumber, taxInvoiceDate, taxInvoiceTime, ""))
        } catch (e: Exception) {
            success(false)
        }
    }

    fun abortTransaction(continueStatus: Int) {
        when(cliSiTef.abortTransaction(continueStatus)) {
            0 -> success(true)
            -1 -> success(false)
        }
    }

    fun continueTransaction(data: String) {
        when(cliSiTef.continueTransaction(data)) {
            0 -> success(true)
            -1 -> success(false)
        }
    }

    private fun processTransactionStatus(transactionStatus: Int) {
        when(transactionStatus) {
            10000 -> success(true)
            0 -> success(true)
            -1 -> error(transactionStatus.toString(), "Module not initialized")
            -2 -> error(transactionStatus.toString(), "Operation aborted by the operator")
            -3 -> error(transactionStatus.toString(), "Invalid functionId")
            -4 -> error(transactionStatus.toString(), "Low memory to run the function")
            -5 -> error(transactionStatus.toString(), "No communication with SiTef server")
            -6 -> error(transactionStatus.toString(), "Operation aborted by the user")
            in 1..Int.MAX_VALUE -> error(transactionStatus.toString(), "Denied by the authorizer")
            in Int.MIN_VALUE..-7 -> error(transactionStatus.toString(), "Errors internally detected by the routine")
        }
    }

    fun getQttPendingTransactions(dataFiscal: String, cupomFiscal: String) {
        try {
            success(cliSiTef.getQttPendingTransactions(dataFiscal, cupomFiscal))
        } catch (e: Exception) {
            error("getQttPendingTransactions", e.toString())
        }
    }

    fun configure(enderecoSiTef: String, codigoLoja: String, numeroTerminal: String, parametrosAdicionais: String) {
        try {
            idConfig = cliSiTef.configure(enderecoSiTef, codigoLoja, numeroTerminal, parametrosAdicionais);
            when(idConfig) {
                0 -> success(true)
                1 -> error(idConfig.toString(), "Invalid enderecoSiTef or not reachable")
                2 -> error(idConfig.toString(), "Invalid codigoLoja")
                3 -> error(idConfig.toString(), "Invalid numeroTerminal")
                6 -> error(idConfig.toString(), "TCP/IP init error")
                7 -> error(idConfig.toString(), "Memory overflow")
                8 -> error(idConfig.toString(), "CliSiTef not found")
                9 -> error(idConfig.toString(), "SiTef Server config exceeded")
                10 -> error(idConfig.toString(), "Could not access CliSiTef dir", "Check for permissions")
                11 -> error(idConfig.toString(), "Invalid data")
                12 -> error(idConfig.toString(), "Safe mode not enabled")
                13 -> error(idConfig.toString(), "Invalid DLL path")
            }
        } catch (e: Error) {
            error("configure", e.toString())
        }
    }

}