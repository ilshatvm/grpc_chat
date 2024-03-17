# Dockerfile
FROM dart:3.3.1-sdk
WORKDIR /app
COPY pubspec.* .
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/main.dart -o server

FROM subfuzion/dart   
COPY --from=0 /app/server .
EXPOSE 4401
CMD ["/server"]