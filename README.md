#### Basic repo to build and test adhoc bash scripts.

```bash
make start  # Starts a centos 7 docker in the backgound
make start PORTS="-p 80:80 -p 3000:3000"    # Starts a docker and maps the defined ports to the host
make stops  # Stops and removes the running docker
make clean  # Clean any zombie dockers
make exec   # Exec into a bash prompt in the running docker.
```
