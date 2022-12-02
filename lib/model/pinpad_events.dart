enum PinPadEvents {
  unknown,
  genericError,
  startBluetooth,
  endBluetooth,
  waitingPinPadConnection,
  pinPadOk,
  waitingPinPadBluetooth,
  pinPadBluetoothConnected,
  pinPadBluetoothDisconnected,
}

extension PinPadEventsString on String  {
  PinPadEvents get pinPadEvent {
    switch (this) {
      case 'GENERIC_ERROR':
        return PinPadEvents.genericError;
      case 'EVT_INICIA_ATIVACAO_BT':
        return PinPadEvents.startBluetooth;
      case 'EVT_FIM_ATIVACAO_BT':
        return PinPadEvents.endBluetooth;
      case 'EVT_INICIA_AGUARDA_CONEXAO_PP':
        return PinPadEvents.waitingPinPadConnection;
      case 'EVT_FIM_AGUARDA_CONEXAO_PP':
        return PinPadEvents.pinPadOk;
      case 'EVT_PP_BT_CONFIGURANDO':
        return PinPadEvents.waitingPinPadBluetooth;
      case 'EVT_PP_BT_CONFIGURADO':
        return PinPadEvents.pinPadBluetoothConnected;
      case 'EVT_PP_BT_DESCONECTADO':
        return PinPadEvents.pinPadBluetoothDisconnected;
    }
    return PinPadEvents.unknown;
  }
}