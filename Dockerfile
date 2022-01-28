# imagem para execucao da aplicacao
FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base

# definir o diretorio de execucao da aplicacao
WORKDIR /app

# criar um usuario que ira executar a aplicacao 
# nao root e com UID explicito // adicionar 
RUN adduser -u 5678 --disabled-password --gecos "" appuser 

# adicionar a permissao para acessar a pasta /app
RUN chown -R appuser /app

# adicionar a permissao leitura, gravacao e execucao para a pasta /app
RUN chmod -R 777 /app

# definir o usuario que ira executar a aplicacao
USER appuser

# definir a variavel de ambiente que expoe a porta de execuca da aplicacao
ENV ASPNETCORE_URLS=http://+:5000

# definir a porta que sera exposta no nosso container
EXPOSE 5000/tcp

# imagem do SDK para build da aplicacao
FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build

# diretorio com os fontes para build da apliacacao
WORKDIR /source

# copiar o fonte do projeto para executar o build da aplicacao 
COPY . .

# executar o restore dos pacotes utilizados no projeto
RUN dotnet restore src/

# executar o build da aplicacao
RUN dotnet build src/ -c Release -o /app/build

# imagem do SKD para publish da aplicacao
FROM build AS publish

# executar o publish da aplicacao
RUN dotnet publish src/ -c Release -o /app/publish

# imagem do ASPNET para execucao da aplicacao
FROM base AS final

# definir o diretorio de execucao da aplicacao
WORKDIR /app

# copiar os arquivos da pasta publish da nossa imagem do SKD para a pasta /app da imagem final
COPY --from=publish /app/publish .

# executando a aplicacao
ENTRYPOINT ["dotnet", "DotnetDebugDockerContainerWebApi.dll"]
