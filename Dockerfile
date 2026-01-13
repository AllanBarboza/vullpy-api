# =========================
# STAGE 1 - BUILD
# =========================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# Copia a solution
COPY *.sln ./

# Copia os csproj individualmente (cache eficiente)
COPY Vullpy.API/*.csproj Vullpy.API/
COPY Vullpy.Application/*.csproj Vullpy.Application/
COPY Vullpy.Domain/*.csproj Vullpy.Domain/
COPY Vullpy.IoC/*.csproj Vullpy.IoC/
COPY Vullpy.Infrastructure/*.csproj Vullpy.Infrastructure/

# Restaura dependências APENAS da API
RUN dotnet restore Vullpy.API/Vullpy.API.csproj

# Copia todo o restante do código
COPY . .

# Publica somente o projeto da API
RUN dotnet publish Vullpy.API/Vullpy.API.csproj \
    -c Release \
    -o /app/publish

# =========================
# STAGE 2 - RUNTIME
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

COPY --from=build /app/publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "Vullpy.API.dll"]
