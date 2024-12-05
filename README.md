# RV1106 buildroot

> [!WARNING]  
> This is still very much work in progress and not suitable for being used in dev or production environments

## Build the docker image

```bash
docker buildx build --platform linux/amd64 -f Dockerfile -t olel/rv1106-buildroot:latest .
```
