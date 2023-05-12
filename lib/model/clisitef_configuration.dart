library clisitef;

class CliSiTefConfiguration {
  CliSiTefConfiguration(
      {required this.enderecoSitef,
      required this.codigoLoja,
      required this.numeroTerminal,
      required this.cnpjLoja,
      required this.cnpjEmpresa});

  final String enderecoSitef;

  final String codigoLoja;

  final String numeroTerminal;

  final String cnpjLoja;

  final String cnpjEmpresa;
}
