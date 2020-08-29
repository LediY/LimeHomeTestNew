#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["LimeHomeTest.Web/LimeHomeTest.Web.csproj", "LimeHomeTest.Web/"]
COPY ["LimeHomeTest.Services/LimeHomeTest.Services.csproj", "LimeHomeTest.Services/"]
COPY ["LimeHomeTest.Repository/LimeHomeTest.Repository.csproj", "LimeHomeTest.Repository/"]
COPY ["LimeHomeTest.Dto/LimeHomeTest.Dto.csproj", "LimeHomeTest.Dto/"]
COPY ["LimeHomeTest.Tests/LimeHomeTest.Tests.csproj", "Tests/LimeHomeTest.Tests/"]
RUN dotnet restore "LimeHomeTest.Web/LimeHomeTest.Web.csproj"
COPY . .

# testing
WORKDIR /src/LimeHomeTest.Web
RUN dotnet build
WORKDIR /src/LimeHomeTest.Tests
RUN dotnet test

WORKDIR "/src/LimeHomeTest.Web"
RUN dotnet build "LimeHomeTest.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "LimeHomeTest.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
CMD ASPNETCORE_URLS=http://*:$PORT dotnet LimeHomeTest.Web.dll