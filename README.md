# Journey

**_Version v1.0.0_**

Bash project to get docker images from specific repository

Developped in Bash `v5.2.15`

## Index

-   [Get Started](#get-started)
-   [Trouble-shootings](#trouble-shootings)
-   [Credits](#credits)

## Get Started

1. Clone the project

```bash
git clone
```

2. Create alias
    - Open bash aliases file
    ```bash
    vim ~/.bash_aliases
    ```
    - Then put this line replacing `<PATH_TO_REPO>` to the real path of the repository
    ```bash
    alias journey="<PATH_TO_REPO>/journey.sh"
    ```
    - Then in your `~/.bashrc` or `~/bash_profile` execute `bash_aliases` with this
    ```bash
    if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
    fi
    ```
3. Launch the script

```bash
journey
# What registry do you want to read images (Ex: castimaging) : lucasnoga
```

4. If needed several options are available
    - Debug mode
    ```bash
    journey --debug
    ```
    - Help
    ```bash
    journey --help
    ```
    - Version
    ```bash
    journey --version
    ```

## Trouble-shootings

If you have any difficulties, problems or enquiries please let me an issue [here](https://github.com/NY-Daystar/Journey/issues/new)

## Credits

Made by Lucas Noga  
Licensed under GPLv3.
