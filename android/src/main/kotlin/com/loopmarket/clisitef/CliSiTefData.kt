package com.loopmarket.clisitef

class CliSiTefData(
    val event: DataEvents,
    val currentStage: Int,
    val buffer: String = "",
    val shouldContinue: Boolean = true,
    val fieldId: Int = 0,
    val maxLength: Int = 0,
    val minLength: Int = 0
) {
    fun toDataSink(): Map<String, Any> {
        return mapOf(
            "event" to event.named,
            "currentStage" to currentStage,
            "buffer" to buffer,
            "shouldContinue" to shouldContinue,
            "fieldId" to fieldId,
            "maxLength" to maxLength,
            "minLength" to minLength
        )
    }
}
