# Build image
FROM microsoft/dotnet:2.1.300-sdk AS builder

# set up node
ENV NODE_VERSION 10.7.0
ENV NODE_DOWNLOAD_SHA 7324a356b31833c3a978705640d3736a88ec0146bcc1c7ae8875c41d89d4b4da
RUN curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && npm install -g bower gulp


WORKDIR /sln

COPY ./build.sh ./build.cake   ./

# Install Cake, and compile the Cake build script
RUN ./build.sh -Target=Clean

# Copy all the csproj files and restore to cache the layer for faster builds
# The dotnet_build.sh script does this anyway, so superfluous, but docker can 
# cache the intermediate images so _much_ faster
COPY ./demoweb.sln ./  
COPY ./src/web/web.csproj  ./src/web/web.csproj  
COPY ./tests/tests/tests.csproj  ./tests/tests/tests.csproj 
RUN /bin/bash ./build.sh -Target=Restore

COPY ./tests ./tests
COPY ./src ./src


# Build, Test, and Publish
RUN ./build.sh -Target=Build && ./build.sh -Target=Test && ./build.sh -Target=PublishWeb

#App image
FROM microsoft/dotnet:2.1.1-aspnetcore-runtime
WORKDIR /app  
ENV ASPNETCORE_ENVIRONMENT Production
ENV ASPNETCORE_URLS http://+:4000
EXPOSE 4000
ENTRYPOINT ["dotnet", "web.dll"]  
COPY --from=builder ./sln/dist .  
