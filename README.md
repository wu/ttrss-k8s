# ttrss-k8s

Build a Tiny Tiny RSS docker container and deploy it in kubernetes
with helm on digitalocean.

Warning: I'm learning helm, and this is my first attempt to build a
helm chart.


Here's how I use this repository.  All these commands are executed
from the root of the project.

        # build the docker container
        docker-compose build

I publish the image to a private docker registry on DO that I set up using these instructions:

  * https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04
  * https://www.digitalocean.com/docs/kubernetes/how-to/set-up-registry/

Then I use helm to install and configure ttrss on kubernetes.
Customize the values.yaml and/or yaml files to fit your requirements.

        # install
        helm install ttrssk8s helm

        # uninstall, persistent volumes not removed
        helm uninstall ttrssk8s


I am using digital ocean block storage for persistent volumes.  If you
use helm to uninstall and then reinstall, it will properly reconnect
to the persistent volumes.  I'm not sure if 'helm upgrade' works
properly yet.

I'm also using an nginx ingress with a digital ocean load balancer.

  * https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes


# docker container to kubernetes

The docker container build was forked from this project:

  * https://github.com/x86dev/docker-ttrss

It includes a number of changes for kubernetes.

Several configuration files have been moved to kubernetes configmaps,
which are mounted as files into the containers on startup.  This
allows the service to be significantly reconfigured without needing to
rebuild the docker container.

The database initialization script is now stored in a hashmap, and is
mounted as a file at runtime into /docker-entrypoint-initdb.d, which
is used by the postgres container to initialize the database when it
does not exist on container startup.

  * https://hub.docker.com/_/postgres/

I originally set this up as a kubernetes deploy, but changed it to a
statefulset to resolve an issue where the persistent volumes were
deleted on uninstallation.
