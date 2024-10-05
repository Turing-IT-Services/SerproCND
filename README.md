# SerproAPI

`SerproAPI` é um pacote Swift que fornece uma interface para autenticar e consumir a API de Certidão do SERPRO. Ele utiliza o protocolo OAuth2 para autenticação e oferece métodos para realizar consultas de Certidão Negativa de Débitos (CND).

## Requisitos

- iOS 13.0+ / macOS 10.15+
- Swift 5.7+

## Instalação

Adicione o `SerproAPI` ao seu projeto Swift Package Manager:

1. No Xcode, vá para `File > Swift Packages > Add Package Dependency`.
2. Insira o URL do repositório: `https://github.com/seu-usuario/SerproAPI.git`.
3. Selecione a versão desejada e adicione o pacote ao seu projeto.

## Uso

### Inicialização


swift import SerproAPI

let serproAPI = SerproAPI(consumerKey: "your_consumer_key", consumerSecret: "your_consumer_secret")
### Autenticação

Antes de realizar consultas, você deve autenticar-se para obter um token de acesso:


swift serproAPI.authenticate { result in switch result { case .success(): print("Autenticação bem-sucedida") case .failure(let error): print("Erro de autenticação: (error)") } }
### Consulta de Certidão

Após a autenticação, você pode realizar consultas de Certidão:


swift serproAPI.consultaCND(tipoContribuinte: .pessoaJuridica, contribuinteConsulta: "00000000000001", codigoIdentificacao: "9001", gerarCertidaoPdf: true) { result in switch result { case .success(let response): print("Consulta bem-sucedida: (response)") case .failure(let error): print("Erro na consulta: (error)") } }
## Tratamento de Erros

O pacote define erros específicos que podem ser tratados:

- `SerproError.invalidCredentials`: Credenciais inválidas.
- `SerproError.noData`: Nenhum dado recebido.
- `SerproError.invalidResponse`: Formato de resposta inválido.
- `SerproError.noAccessToken`: Token de acesso não disponível.
- `SerproError.processingKey(String)`: Consulta em processamento, chave retornada.
- `SerproError.serverError(Int, String)`: Erro do servidor com código e mensagem.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## Licença

Este projeto é licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
