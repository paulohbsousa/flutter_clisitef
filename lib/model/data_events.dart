enum DataEvents {
  unknown,
  pressAnyKey,
  message,
  menuTitle,
  menuOptions,
  data,
  getField
}

extension DataEventsString on String  {
  DataEvents get dataEvent {
    switch (this) {
      case 'PRESS_ANY_KEY':
        return DataEvents.pressAnyKey;
      case 'MESSAGE':
        return DataEvents.message;
      case 'MENU_TITLE':
        return DataEvents.menuTitle;
      case 'MENU_OPTIONS':
        return DataEvents.menuOptions;
      case 'DATA':
        return DataEvents.data;
      case 'GET_FIELD':
        return DataEvents.getField;
    }
    return DataEvents.unknown;
  }
}