# Bitwarden CLI

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `bitwarden`

## Что это

Официальный CLI менеджера паролей Bitwarden. Команда: `bw`.

## Зачем нужен

Доступ к хранилищу паролей из терминала и скриптов: логин, поиск, копирование секретов, unlock сессии.

## Примеры

```bash
bw login
bw unlock
bw list items --search github
bw get password <item-name>
bw sync
```

## Установка через CLI Toolbox

```bash
./install.sh --only bitwarden
./install.sh --profile admin
./install.sh --update --only bitwarden
```

- macOS: Homebrew `bitwarden-cli`
- Linux: Snap (`bw`) или официальный бинарник в `~/.local/bin`
- arm64 без brew: `npm install -g @bitwarden/cli`

Определение: [`catalog/tools/bitwarden.yaml`](../../catalog/tools/bitwarden.yaml).

## Ссылки

- [Bitwarden CLI](https://bitwarden.com/help/cli/)
- [GitHub clients](https://github.com/bitwarden/clients)
