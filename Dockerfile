# build
FROM microsoft/aspnetcore-build:2 as build

WORKDIR /generator

# restore
COPY api/*.csproj ./api/
RUN dotnet restore api/api.csproj
COPY tests/*.csproj ./tests/
RUN dotnet restore tests/tests.csproj

# copy src
COPY . .

# test
ENV TEAMCITY_PROJECT_NAME=fake
RUN dotnet test tests/tests.csproj

# publish
RUN dotnet publish api/api.csproj /p:TargetManifestFiles= -o /publish

# runtime stage
FROM microsoft/aspnetcore:2 as runtime
WORKDIR /publish
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "api.dll"]