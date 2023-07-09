# Generating the Images (Before Playing the Game)

## Prerequisites
To run, you must have the following installed:
- [docker](https://docs.docker.com/engine/install/)
- [GNU parallel](https://askubuntu.com/questions/634829/installing-gnu-parallel-utility-on-ubuntu-14-04)

You can start docker by running `sudo service docker start`.

## Inferencing
Repo: [GitHub repo](https://github.com/fboulnois/stable-diffusion-docker) bc I'm running behind and don't want to fight with github submodules...

1. Add your HF token (read) to `generate_assets/token.txt`:
    ```txt
    hf_...
    ```

2. Clone the repo:
    ```bash
    $ git clone https://github.com/fboulnois/stable-diffusion-docker.git dockerized_stablediff/
    ```

3. To make it easier to output into the right place for the Flutter app, change `dockerized_stablediff/build.sh:30`:
    ```bash
    ...
    # OLD: -v "$PWD"/output:/home/huggingface/output \
    -v "$PWD"/../../app/assets/images/dogs:/home/huggingface/output \
    ...
    ```
    AND on line `45`:
    ```bash
    ...
    # OLD: -v "$PWD"/output:/home/huggingface/output \
    -v "$PWD"/../../app/assets/images/dogs:/home/huggingface/output \
    ...
    ```

4. Pull the latest docker image:
    ```bash
    $ sh dockerized_stablediff/build.sh pull # might need sudo if using WSL
    ```

5. Generate the images:
    ```bash
    $ sh runme.sh run
    ```