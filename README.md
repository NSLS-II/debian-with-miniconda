Set the env var for the user name:
```
export DOCKER_ID_USER="username"
```

Login to docker:
```
docker login
```

Build the image based on the Dockerfile:

```bash
docker image build . --no-cache
```

At the end of the execution it will provide the uid of the build:
```
Preparing transaction: ...working... done
Verifying transaction: ...working... done
Executing transaction: ...working... done
Removing intermediate container e3abb8e9538b
 ---> c34009bf2097
Successfully built c34009bf2097
```

Tag the image:
```
docker tag c34009bf2097 $DOCKER_ID_USER/debian-with-miniconda
```

Push the image:
```
docker push $DOCKER_ID_USER/debian-with-miniconda
```

----

Documentation:
- https://docs.docker.com/engine/reference/commandline/image_build/
- https://docs.docker.com/docker-cloud/builds/push-images/


