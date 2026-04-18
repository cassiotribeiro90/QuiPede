class CadastroInfoModel {
  final String nome;
  final String email;
  final String telefone;
  final String senha;
  final String confirmarSenha;

  CadastroInfoModel({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
    required this.confirmarSenha,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'senha': senha,
    'confirmar_senha': confirmarSenha,
  };
}

class CadastroEnderecoModel {
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final String? apelido;
  final bool padrao;
  final String tipo;

  CadastroEnderecoModel({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.apelido,
    this.padrao = true,
    this.tipo = 'entrega',
  });

  Map<String, dynamic> toJson() => {
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'complemento': complemento,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
    'apelido': apelido,
    'padrao': padrao ? 1 : 0,
    'tipo': tipo,
  };
}
