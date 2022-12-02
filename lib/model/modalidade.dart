library clisitef;

enum Modalidade {
  generic,
  debit,
  credit,
  voucher,
  test
}

extension ModalidadeExtension on Modalidade  {
  int get value {
    switch (this) {
      case Modalidade.generic:
        return 0;
      case Modalidade.debit:
        return 2;
      case Modalidade.credit:
        return 3;
      case Modalidade.voucher:
        return 5;
      case Modalidade.test:
        return 6;
    }
  }
}