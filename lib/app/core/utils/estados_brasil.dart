/// Mapa de nomes completos dos estados para suas siglas.
const Map<String, String> estadosBrasil = {
  'Acre': 'AC',
  'Alagoas': 'AL',
  'Amapá': 'AP',
  'Amazonas': 'AM',
  'Bahia': 'BA',
  'Ceará': 'CE',
  'Distrito Federal': 'DF',
  'Espírito Santo': 'ES',
  'Goiás': 'GO',
  'Maranhão': 'MA',
  'Mato Grosso': 'MT',
  'Mato Grosso do Sul': 'MS',
  'Minas Gerais': 'MG',
  'Pará': 'PA',
  'Paraíba': 'PB',
  'Paraná': 'PR',
  'Pernambuco': 'PE',
  'Piauí': 'PI',
  'Rio de Janeiro': 'RJ',
  'Rio Grande do Norte': 'RN',
  'Rio Grande do Sul': 'RS',
  'Rondônia': 'RO',
  'Roraima': 'RR',
  'Santa Catarina': 'SC',
  'São Paulo': 'SP',
  'Sergipe': 'SE',
  'Tocantins': 'TO',
};

/// Converte o nome do estado para sigla (ex: "Minas Gerais" -> "MG").
/// Se já for uma sigla válida (2 letras maiúsculas), retorna ela mesma.
String converterEstadoParaSigla(String nome) {
  final nomeTrim = nome.trim();
  if (nomeTrim.isEmpty) return '';

  // Se já for uma sigla (2 caracteres maiúsculos), retorna ela mesma
  if (RegExp(r'^[A-Z]{2}$').hasMatch(nomeTrim)) {
    return nomeTrim.toUpperCase();
  }

  // Tenta converter via mapa
  final sigla = estadosBrasil[nomeTrim];
  if (sigla != null) return sigla;

  // Fallback: pega as duas primeiras letras em maiúsculo
  if (nomeTrim.length >= 2) {
    return nomeTrim.substring(0, 2).toUpperCase();
  }
  
  return nomeTrim.toUpperCase();
}
